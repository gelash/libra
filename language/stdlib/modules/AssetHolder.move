// TODO: assert that DefaultToken has a single band.
address 0x1 {

    module AssetHolder {
        use 0x1::IssuerToken::{Self,
                               IssuerToken,
                               DefaultToken};
        use 0x1::LibraTimestamp;

        resource struct AssetHolder<AssetType> {
            asset: AssetType,
        }

        /// Returns an AssetHolder holding IssuerToken<DefaultToken> with
        /// amount = starting_amount. Note: Band for DefaultToken is always 0.
        public fun create_default_issuer_token_holder(
            issuer: &signer,
            starting_amount: u64,
        ): AssetHolder<IssuerToken<DefaultToken>> {
            AssetHolder<IssuerToken<DefaultToken>> {
                asset: IssuerToken::mint_issuer_token<DefaultToken>(
                    issuer,
                    0,
                    starting_amount)
            }
        }
        
        /// Can only be called during genesis with libra root account.
        public fun initialize(lr_account: &signer) {
            LibraTimestamp::assert_genesis();

            // Publish for relevant IssuerToken types.
            move_to(lr_account,
                    create_default_issuer_token_holder(lr_account, 0));
        }

        /// Adds IssuerToken<DefaultToken> to the AssetHolder on issuer's
        /// account. Note: For now, band for DefaultToken is always 0. 
        public fun top_up_default_issuer_token_holder(
            issuer: &signer,
            holder: &mut AssetHolder<IssuerToken<DefaultToken>>,
            amount: u64,
        ) {
            // TODO: maybe assert that it's for holder is for the same issuer.
            IssuerToken::merge_issuer_token<DefaultToken>(
                &mut holder.asset,
                IssuerToken::mint_issuer_token<DefaultToken>(issuer,
                                                             0,
                                                             amount));
        }

        /// Takes IssuerToken<DefaultToken> from the AssetHolder on issuer's
        /// account and deposits on receivers account (stored in IssuerTokens
        /// struct). Note: For now, band for DefaultToken is always 0. 
        public fun deposit_default_issuer_token(
            receiver: &signer,
            holder: &mut AssetHolder<IssuerToken<DefaultToken>>,
            amount: u64,
        ) {
            let issuer_tokens =
                IssuerToken::split_issuer_token<DefaultToken>(&mut holder.asset,
                                                              amount);

            // This call also asserts that receiver != issuer
            IssuerToken::deposit_issuer_token<DefaultToken>(receiver,
                                                            issuer_tokens);
        }

        // TODO: also do burn for default (and moneyorder) issuer tokens.
    }
    
}
