// TODO: add comments. 
address 0x1 {

    module IssuerToken {
        use 0x1::Signer;
        use 0x1::LibraTimestamp;
        use 0x1::Vector;
        
        struct DefaultToken { }

        struct GenerationToken {
            generation: u64,
        }

        public fun token_equals(token_a: DefaultToken,
                                token_b: DefaultToken,
        ): bool {
            true
        }

        public fun token_equals(token_a: GenerationToken,
                                token_b: GenerationToken,
        ): bool {
            token_a.generation == token_b.generation
        }

        resource struct IssuerToken<TokenType> {
            issuer_address: address,
            
            amount: u64,
            
            sub_token: TokenType, 
        }

        // Container for storing tokens.
        resource struct IssuerTokenWallet<IssuerTokenType> {
            // TODO: A Map would be a better data-structure when available.
            issuer_tokens: vector<IssuerTokenType>,
        }

        public fun publish_token_wallet<IssuerTokenType>(sender: &signer)
        {
            let sender_address = Signer::address_of(sender);
            
            if (!exists<IssuerTokenWallet<IssuerTokenType>>(sender_address)) {
                move_to(sender, IssuerTokenWallet<IssuerTokenType> {
                    tokens: Vector<IssuerTokenType>::empty(),
                });
            }
        }
        
        public fun initialize(sender: &signer)
        {
            LibraTimestamp::assert_genesis();

            // Publish the wallet for existing IssuerToken types.
            publish_token_wallet<IssuerToken<DefaultToken>>(sender);
            publish_token_wallet<IssuerToken<GenerationToken>>(sender);
        }
        
        // Implements finding a issuer token based on address and sub-token.
        fun find_issuer_token<TokenType>(
            issuer_token_vector: &vector<IssuerToken<TokenType>>,
            issuer_address: address,
            sub_token: TokenType,
        ): (bool, u64) {
            let i = 0;
            while (i < Vector::length(issuer_token_vector)) {
                let coin = Vector::borrow(issuer_token_vector, i);
                if (coin.issuer_address == issuer_address &&
                    token_equals(coin.sub_token, sub_token)) return (true, i);
                i = i + 1;
            };
            (false, 0)
        }

        public fun issuer_token_balance<TokenType>(sender: &signer,
                                                   issuer_address: address,
                                                   sub_token: TokenType,
        ) : u64 acquires IssuerTokenWallet<IssuerToken<TokenType>> {
            let sender_address = Signer::address_of(sender);

            if (!exists<IssuerTokenWallet<IssuerToken<TokenType>>>(sender_address)) {
                return 0;
            }
            let wallet_vec =
                borrow_global<IssuerTokenWallet<IssuerToken<TokenType>>>(sender_address);
            
            let (found, issuer_token_index) =
                find_issuer_token<TokenType>(&wallet_vec.issuer_tokens,
                                             issuer_address,
                                             sub_token);
            if (!found) return 0;

            let issuer_token = Vector::borrow(&wallet_vec.issuer_tokens, issuer_token_index);
            issuer_token.amount
        }
        
    }

}
