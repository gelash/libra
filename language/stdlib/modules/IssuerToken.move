// 8004: insufficient balance on issuer's account
// 8005: Issuer depositing own coins on its account (in IssuerTokenContainer structure).
// 8006: Trying to merge different issuer tokens.
// 9000: general error until we move to use Errors module
address 0x1 {

    module IssuerToken {
        use 0x1::Signer;
        use 0x1::LibraTimestamp;
        use 0x1::Vector;
        use 0x1::Event::{Self, EventHandle};

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

        /// BurnIssuerTokenEvents when emitted, serve as a unique certificate
        /// for the burnt amount of the specified issuer token type - since once
        /// an amount is burnt, it's subtracted from the available amount.
        struct BurnIssuerTokenEvent {
            /// Information identifying the issuer token. 'specialization_id' is
            /// a byte that specifies the what <TokenType> parameter was used
            /// according to a fixed convention (currently, we use the declaration
            /// order in this module, e.g. DefaultToken is 0, MoneyOrderToken is 1).
            specialization_id: u8,
            issuer_address: address,
            band_id: u64,

            /// Amount of the IssuerTokens that was burnt.
            burnt_amount: u64,
            
            // Note: could also record left_amount. TODO: consider adding.
        }

        /// The main IssuerToken wrapper resource. Shouldn't be stored on accounts
        /// directly, but rather be wrapped inside IssuerTokenContainer for tokens
        /// issued by other accounts, and BalanceHolder for distributing tokens
        /// issued by the holding account. Once distributed, issuer tokens should
        /// never go back to issuer, they can only be 'burned' back to the issuer.
        /// Note: DefaultToken specialization uses a single band.
        resource struct IssuerToken<TokenType> {
            /// The issuer is the only entity that can authorize issuing these
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
        resource struct IssuerTokenContainer<IssuerTokenType> {
            // TODO: A Map keyed by address and generation would be a better
            // data-structure, when it becomes available.
            issuer_tokens: vector<IssuerTokenType>,

            /// Event stream for burning IssuerTokens (where BurnIssuerTokenEvents
            /// are emitted).
            burn_events: EventHandle<BurnIssuerTokenEvent>,
        }

        /// Publishes the IssuerTokenContainer struct on sender's account, allowing it
        /// to hold tokens of IssuerTokenType issued by other accounts.
        public fun publish_issuer_tokens<IssuerTokenType>(sender: &signer) {
            let sender_address = Signer::address_of(sender);
            
            if (!exists<IssuerTokenContainer<IssuerTokenType>>(sender_address)) {
                move_to(sender, IssuerTokenContainer<IssuerTokenType> {
                    issuer_tokens: Vector::empty(),
                    burn_events: Event::new_event_handle<BurnIssuerTokenEvent>(sender)
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

        /// Returns the balance of a particular IssuerToken type (determined by the
        /// TokenType specialization, issuer_address and band_id) on senders account
        /// (in its IssuerTokenContainer to be precise). If the container doesn't exist
        /// or contain the type of IssuerToken, value 0 is returned.
        /// Note: One of the primary uses of this function is for the unit tests.
        public fun issuer_token_balance<TokenType>(sender: &signer,
                                                   issuer_address: address,
                                                   band_id: u64,
        ): u64 acquires IssuerTokenContainer {
            let sender_address = Signer::address_of(sender);
            if (!exists<IssuerTokenContainer<IssuerToken<TokenType>>>(sender_address)) {
                return 0
            };
            let sender_tokens =
                borrow_global<IssuerTokenContainer<IssuerToken<TokenType>>>(sender_address);
            
            let (found, target_index) =
                find_issuer_token<TokenType>(&sender_tokens.issuer_tokens,
                                             issuer_address,
                                             band_id);
            if (!found) return 0;

            let issuer_token = Vector::borrow(&sender_tokens.issuer_tokens, target_index);
            issuer_token.amount
        }
        
        /// Deposits the issuer token in the IssuerTokenContainer structure on receiver's account.
        /// It's asserted that receiver != issuer, and IssuerTokenContainer<TokenType> is created
        /// if not already published on the receiver's account.
        public fun deposit_issuer_token<TokenType>(receiver: &signer,
                                                   issuer_token: IssuerToken<TokenType>,
        ) acquires IssuerTokenContainer {
            let receiver_address = Signer::address_of(receiver);
            assert(issuer_token.issuer_address != receiver_address, 8005);
            
            if (!exists<IssuerTokenContainer<IssuerToken<TokenType>>>(receiver_address)) {
                publish_issuer_tokens<IssuerToken<TokenType>>(receiver);
            };
            let receiver_tokens =
                borrow_global_mut<IssuerTokenContainer<IssuerToken<TokenType>>>(receiver_address);

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

        // Destroys the given token and emits the BurnIssuerToken event on the provided
        // handle. We bottleneck burn_to_issuer functionality to go through the
        // IssuerTokenContainer structure (which contains the burn event handle): i.e.
        // in order to burn a given issuer token, the sender shold first deposit it to
        // the container, then burn it. This is a minor inconvenience on the caller side,
        // but makes the IssuerToken module implementation and APIs cleaner.
        fun burn_issuer_token<TokenType>(to_burn_token: IssuerToken<TokenType>,
                                         event_handle: &mut EventHandle<BurnIssuerTokenEvent>,
                                         specialization_id: u8,
        ) {
             // Destroy the actual token.
            let IssuerToken<TokenType> {issuer_address,
                                        band_id,
                                        amount,} = to_burn_token;
            // Can't burn non-positive amounts. Negative amounts don't make sense, and while
            // it's okay to destroy IssuerToken with 0 amount, it doesn't need burn events.
            assert(amount > 0, 9000);
            
            // Emit the corresponding burn event.
            Event::emit_event(
                event_handle,
                BurnIssuerTokenEvent {
                    specialization_id: specialization_id,
                    issuer_address: issuer_address,
                    band_id: band_id,
                    burnt_amount: amount,
                }
            );
        }

        fun burn_to_issuer<TokenType>(sender: &signer,
                                      specialization_id: u8,
                                      issuer_address: address,
                                      band_id: u64,
                                      to_burn_amount: u64,
        ) acquires IssuerTokenContainer {
            assert(to_burn_amount > 0, 9000);
            
            let sender_address = Signer::address_of(sender);
            assert(exists<IssuerTokenContainer<IssuerToken<TokenType>>>(sender_address), 9000);
            let sender_tokens =
                borrow_global_mut<IssuerTokenContainer<IssuerToken<TokenType>>>(sender_address);

            let (found, target_index) =
                find_issuer_token<TokenType>(&sender_tokens.issuer_tokens,
                                             issuer_address,
                                             band_id);
            assert(found, 9000);
            let issuer_token = Vector::borrow_mut(&mut sender_tokens.issuer_tokens, target_index);
            assert(issuer_token.amount >= to_burn_amount, 9000);

            // Split the issuer_token, burn the specified amount and emit corresponding event.
            burn_issuer_token<TokenType>(split_issuer_token<TokenType>(issuer_token,
                                                                       to_burn_amount),
                                         &mut sender_tokens.burn_events,
                                         specialization_id);

            // Clear the IssuerToken from Container if the amount is 0.
            // Note: we could make this a private utility function if useful elsewhere.
            if (issuer_token.amount == 0){
                let IssuerToken<TokenType> {issuer_address: _,
                                            band_id: _,
                                            amount: _ } =
                    Vector::swap_remove(&mut sender_tokens.issuer_tokens, target_index);
            };
        }

        fun burn_all_to_issuer<TokenType>(sender: &signer,
                                          specialization_id: u8,
                                          issuer_address: address,
                                          band_id: u64,
        ) acquires IssuerTokenContainer {
            let total_amount = issuer_token_balance<TokenType>(sender, issuer_address, band_id);
            
            // burn_to_issuer will check that total_amount > 0.
            burn_to_issuer<TokenType>(sender,
                                      specialization_id,
                                      issuer_address,
                                      band_id,
                                      total_amount);
        }

        public fun burn_all_issuer_default_tokens(sender: &signer,
                                                  issuer_address: address,
                                                  band_id: u64,
        ) acquires IssuerTokenContainer {
            burn_all_to_issuer<DefaultToken>(sender, 0, issuer_address, band_id);
        }

        public fun burn_issuer_default_tokens(sender: &signer,
                                              issuer_address: address,
                                              band_id: u64,
                                              to_burn_amount: u64,
        ) acquires IssuerTokenContainer {
            burn_to_issuer<DefaultToken>(sender, 0, issuer_address, band_id, to_burn_amount);
        }
    }

}
