address 0x1 {

    module DefaultToken {
        use 0x1::AssetHolder::{Self, AssetHolder};
        use 0x1::Errors;
        use 0x1::IssuerToken::{Self, IssuerToken};
        use 0x1::LibraTimestamp;
        use 0x1::Signer;
        
        /// Default empty info struct for templating IssuerToken on, i.e. having
        /// different specializations of the same issuer token functionality.
        /// By convention, DefaultToken won't make use of IssuerToken's 'band'
        /// functionality (i.e. band_id will always be set to 0).
        struct DefaultToken { }

        /// Adding IssuerToken to non-issuer's AssetHolder
        const ECANNOT_ADD_TO_OTHERS: u64 = 0;
        /// Adding IssuerToken with non-positive amount
        const EADD_NON_POSITIVE: u64 = 1;
        /// Receiving IssuerToken with non-positive amount
        const ERECEIVE_NON_POSITIVE: u64 = 2;
        
        /// Can only be called during genesis with libra root account.
        public fun initialize(lr_account: &signer) {
            LibraTimestamp::assert_genesis();

            AssetHolder::publish_zero_issuer_token_holder<DefaultToken>(
                lr_account);

            IssuerToken::publish_issuer_token_container<DefaultToken>(
                lr_account);
            IssuerToken::register_token_specialization<DefaultToken>(
                lr_account, 0);
        }

        /// Adds IssuerToken<DefaultToken> to the AssetHolder. Asserts that
        /// the AssetHolder's owner is the issuer.
        public fun asset_holder_top_up(
            issuer: &signer,
            holder: &mut AssetHolder<IssuerToken<DefaultToken>>,
            amount: u64,
        ) {
            // Issuer should be the holder's owner.
            assert(
                AssetHolder::owner<DefaultToken>(holder) ==
                    Signer::address_of(issuer),
                Errors::invalid_argument(ECANNOT_ADD_TO_OTHERS));
            // Top up amount should be positive.
            assert(amount > 0,
                   Errors::invalid_argument(EADD_NON_POSITIVE)); 
            
            IssuerToken::merge_issuer_token<DefaultToken>(
                AssetHolder::borrow_issuer_token_mut<DefaultToken>(holder),
                IssuerToken::mint_issuer_token<DefaultToken>(issuer,
                                                             0, // band_id = 0
                                                             amount));
        }
        
        /// Takes IssuerToken<DefaultToken> from the AssetHolder and deposits
        /// on receivers account (stored in the IssuerTokenContainer struct).
        public fun asset_holder_withdraw(
            receiver: &signer,
            holder: &mut AssetHolder<IssuerToken<DefaultToken>>,
            amount: u64,
        ) {
            // Received amount should be positive.
            assert(amount > 0,
                   Errors::invalid_argument(ERECEIVE_NON_POSITIVE));
            
            let issuer_tokens =
                IssuerToken::split_issuer_token<DefaultToken>(
                    AssetHolder::borrow_issuer_token_mut<DefaultToken>(
                        holder),
                    amount);

            // This call also asserts that receiver != issuer.
            IssuerToken::deposit_issuer_token<DefaultToken>(receiver,
                                                            issuer_tokens);
        }
    }
    
}
