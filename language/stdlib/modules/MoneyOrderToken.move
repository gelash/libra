address 0x1 {

    module MoneyOrderToken {
        use 0x1::AssetHolder::{Self, AssetHolder};
        use 0x1::Errors;
        use 0x1::IssuerToken::{Self, IssuerToken};
        use 0x1::LibraTimestamp;

        /// Empty struct that's used for money orders issuer token functionality.
        /// Makes use of the 'band' feature of the IssuerToken for distinguishing
        /// tokens issued for different batches of money orders (Side note:
        /// when that's not required, DefaultToken can be used instead).
        struct MoneyOrderToken { }

        /// Receiving IssuerToken with non-positive amount
        const ERECEIVE_NON_POSITIVE: u64 = 0;

        /// Can only be called during genesis with libra root account.
        public fun initialize(lr_account: &signer) {
            LibraTimestamp::assert_genesis();

            AssetHolder::publish_zero_issuer_token_holder<MoneyOrderToken>(
                lr_account);

            IssuerToken::publish_issuer_token_container<MoneyOrderToken>(
                lr_account);
            IssuerToken::register_token_specialization<MoneyOrderToken>(
                lr_account, 1);
        }

        /// Issue the specified amount of MoneyOrderTokens of the AssetHolder's
        /// owner with band_id = batch_index and deposit it to the receiver.
        /// The caller of this function (e.g. MoneyOrder module) must have
        /// granted the access. Cannot be used to produce extra tokens because
        /// the issuer's AssetHolder should never be exposed for direct access
        /// (e.g. MoneyOrder module wraps it inside the MoneyOrderAssetHolder
        /// resource and access controls).
        public fun asset_holder_withdraw(
            receiver: &signer,
            holder: &mut AssetHolder<IssuerToken<MoneyOrderToken>>,
            batch_index: u64,
            amount: u64,
        ) {
            // Received amount should be positive.
            assert(amount > 0,
                   Errors::invalid_argument(ERECEIVE_NON_POSITIVE));

            let issuer_tokens =
                IssuerToken::mint_issuer_token_with_capability<MoneyOrderToken>(
                    AssetHolder::borrow_capability<MoneyOrderToken>(holder),
                    AssetHolder::owner<MoneyOrderToken>(holder),
                    batch_index,
                    amount);
            
            // This call also asserts that receiver != issuer.
            IssuerToken::deposit_issuer_token<MoneyOrderToken>(receiver,
                                                               issuer_tokens);
        }
    }
    
}
