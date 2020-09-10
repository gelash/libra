// 8004: insufficient balance on issuer's account
// 8005: Issuer trying to deposit own coins on its account (in IssuerTokens structure).
// 8006: Trying to merge different issuer tokens.
address 0x1 {

    module IssuerToken {
        use 0x1::Signer;
        use 0x1::LibraTimestamp;
        use 0x1::Vector;

        /// Default empty info struct for templating IssuerToken on, i.e. having
        /// different specializations of the same issuer token functionality.
        /// By convention, DefaultToken won't make use of IssuerToken's 'band'
        /// functionality (i.e. band_id will always be set to 0).
        struct DefaultToken { }

        /// Empty struct that's used for money orders issuer token functionality.
        /// Makes use of the 'band' feature of the IssuerToken for distinguishing
        /// tokens issued for different batches of money orders (Side note:
        /// when that's not required, DefaultToken can be used instead).
        struct MoneyOrderToken { }

        /// The main IssuerToken wrapper resource. Shouldn't be stored on accounts
        /// directly, but rather be wrapped inside IssuerTokens for holding (tokens
        /// issued by other accounts) and BalanceHolder for distributing (tokens
        /// issued by the holding account). Once distributed, issuer tokens should
        /// never go back to issuer, they can only be 'burned' back to the issuer.
        /// Note: DefaultToken specialization uses a single band.
        resource struct IssuerToken<TokenType> {
            /// the issuer, is the only entity that can authorize issuing these
            /// tokens (by directly calling, or manual cryptographic guarantees).
            issuer_address: address,

            /// issuer tokens of the same type but different bands can be
            /// treated as different tokens, hence, allowing issuers to issue
            /// differently "typed" tokens at runtime, when needed.
            band_id: u64,

            /// the amount of stored issuer tokens (of the specified type and band).
            amount: u64,
        }

        /// Container for holding redeemed issuer tokens on accounts (i.e.
        /// on accounts other than the issuer).
        resource struct IssuerTokens<IssuerTokenType> {
            // TODO: A Map keyed by address and generation would be a better
            // data-structure, when it becomes available.
            issuer_tokens: vector<IssuerTokenType>,
        }

        /// Publishes the IssuerTokens struct on sender's account, allowing it
        /// to hold tokens of IssuerTokenType issued by other accounts.
        public fun publish_issuer_tokens<IssuerTokenType>(sender: &signer) {
            let sender_address = Signer::address_of(sender);
            
            if (!exists<IssuerTokens<IssuerTokenType>>(sender_address)) {
                move_to(sender, IssuerTokens<IssuerTokenType> {
                    issuer_tokens: Vector::empty(),
                });
            };
        }

        /// Can only be called during genesis with libra root account.
        public fun initialize(lr_account: &signer) {
            LibraTimestamp::assert_genesis();

            // Publish for existing IssuerToken types.
            publish_issuer_tokens<IssuerToken<DefaultToken>>(lr_account);
            publish_issuer_tokens<IssuerToken<MoneyOrderToken>>(lr_account);
        }
        
        // Find the issuer token based on address.
        fun find_issuer_token<TokenType>(
            issuer_token_vector: &vector<IssuerToken<TokenType>>,
            issuer_address: address,
            band_id: u64,
        ): (bool, u64) {
            let i = 0;
            while (i < Vector::length(issuer_token_vector)) {
                let token = Vector::borrow(issuer_token_vector, i);
                if (token.issuer_address == issuer_address &&
                    token.band_id == band_id) {
                    return (true, i)
                };
                
                i = i + 1;
            };
            (false, 0)
        }

        fun create_issuer_token<TokenType>(issuer_address: address,
                                           band_id: u64,
                                           amount: u64,
        ): IssuerToken<TokenType> {
            IssuerToken<TokenType> {
                issuer_address: issuer_address,
                band_id: band_id,
                amount: amount,
            }
        }

        /// Sender can mint arbitrary amounts of its own IssuerToken (with own address).
        public fun mint_issuer_token<TokenType>(issuer: &signer,
                                                band_id: u64,
                                                amount: u64,
        ): IssuerToken<TokenType> {
            let issuer_address = Signer::address_of(issuer);

            create_issuer_token<TokenType>(issuer_address, band_id, amount)
        }

        public fun merge_issuer_token<TokenType>(
            issuer_token_a: &mut IssuerToken<TokenType>,
            issuer_token_b: IssuerToken<TokenType>,
        ) {
            let IssuerToken<TokenType> { issuer_address,
                                         band_id,
                                         amount } = issuer_token_b;
            
            assert(issuer_token_a.issuer_address == issuer_address, 8006);
            assert(issuer_token_a.band_id == band_id, 8006);

            let token_amount = &mut issuer_token_a.amount;
            *token_amount = *token_amount + amount;
        }

        public fun split_issuer_token<TokenType>(
            issuer_token: &mut IssuerToken<TokenType>,
            amount: u64,
        ): IssuerToken<TokenType> {
            assert(issuer_token.amount >= amount, 8004);

            let token_amount = &mut issuer_token.amount;
            *token_amount = *token_amount - amount;

            IssuerToken<TokenType> {
                issuer_address: issuer_token.issuer_address,
                band_id: issuer_token.band_id,
                amount: amount,
            }
        }
        
        public fun issuer_token_balance<TokenType>(sender: &signer,
                                                   issuer_address: address,
                                                   band_id: u64,
        ): u64 acquires IssuerTokens {
            let sender_address = Signer::address_of(sender);
            if (!exists<IssuerTokens<IssuerToken<TokenType>>>(sender_address)) {
                return 0
            };
            let sender_tokens =
                borrow_global<IssuerTokens<IssuerToken<TokenType>>>(sender_address);
            
            let (found, target_index) =
                find_issuer_token<TokenType>(&sender_tokens.issuer_tokens,
                                             issuer_address,
                                             band_id);
            if (!found) return 0;

            let issuer_token = Vector::borrow(&sender_tokens.issuer_tokens, target_index);
            issuer_token.amount
        }
        
        /// Deposits the issuer token in the IssuerTokens structure on receiver's account.
        /// It's asserted that receiver != issuer, and IssuerTokens<TokenType> is created
        /// if not already published on the receiver's account.
        public fun deposit_issuer_token<TokenType>(receiver: &signer,
                                                   issuer_token: IssuerToken<TokenType>
        ) acquires IssuerTokens {
            let receiver_address = Signer::address_of(receiver);
            assert(issuer_token.issuer_address != receiver_address, 8005);
            
            if (!exists<IssuerTokens<IssuerToken<TokenType>>>(receiver_address)) {
                publish_issuer_tokens<IssuerToken<TokenType>>(receiver);
            };
            let receiver_tokens =
                borrow_global_mut<IssuerTokens<IssuerToken<TokenType>>>(receiver_address);

            let (found, target_index) =
                find_issuer_token<TokenType>(&receiver_tokens.issuer_tokens,
                                             issuer_token.issuer_address,
                                             issuer_token.band_id);
            if (!found) {
                // If a issuer token with given type and band_id is not stored,
                // store one with 0 amount.
                target_index = Vector::length(&receiver_tokens.issuer_tokens);
                Vector::push_back(&mut receiver_tokens.issuer_tokens,
                                  create_issuer_token<TokenType>(
                                      issuer_token.issuer_address,
                                      issuer_token.band_id,
                                      0));
            };
            
            // Actually increment the issuer token amount.
            merge_issuer_token(Vector::borrow_mut(&mut receiver_tokens.issuer_tokens,
                                                  target_index),
                               issuer_token);
        }
        
    }

}
