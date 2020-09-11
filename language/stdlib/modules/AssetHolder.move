// TODO: assert that DefaultToken has a single band.
address 0x1 {

    module AssetHolder {
        use 0x1::Coin1::Coin1;
        use 0x1::Coin2::Coin2;
        use 0x1::LBR::LBR;
        use 0x1::Libra::{Self, Libra};
        use 0x1::LibraAccount;
        use 0x1::IssuerToken::{Self,
                               IssuerToken,
                               DefaultToken};
        use 0x1::LibraTimestamp;
        use 0x1::Signer;

        resource struct AssetHolder<AssetType> {
            owner: address,
            
            asset: AssetType,
        }

        /// Returns an AssetHolder holding IssuerToken<DefaultToken> with 0
        /// amount. Note: Band for DefaultToken is always 0.
        public fun create_default_issuer_token_holder(issuer: &signer
        ): AssetHolder<IssuerToken<DefaultToken>> {
            AssetHolder<IssuerToken<DefaultToken>> {
                owner: Signer::address_of(issuer),
                asset: IssuerToken::mint_issuer_token<DefaultToken>(
                    issuer,
                    0,
                    0)
            }
        }

        /// Returns an AssetHolder holding Libra<CoinType> with 0 value.
        public fun create_libra_holder<CoinType>(issuer: &signer
        ): AssetHolder<Libra<CoinType>> {
            AssetHolder<Libra<CoinType>> {
                owner: Signer::address_of(issuer),
                asset: Libra::zero<CoinType>(),
            }
        }
        
        /// Can only be called during genesis with libra root account.
        public fun initialize(lr_account: &signer) {
            LibraTimestamp::assert_genesis();

            // Publish for relevant IssuerToken types.
            move_to(lr_account,
                    create_default_issuer_token_holder(lr_account));
            move_to(lr_account,
                    create_libra_holder<Coin1>(lr_account));
            move_to(lr_account,
                    create_libra_holder<Coin2>(lr_account));
            move_to(lr_account,
                    create_libra_holder<LBR>(lr_account));
        }

        /// Adds IssuerToken<DefaultToken> to the AssetHolder on issuer's
        /// account. Note: For now, band for DefaultToken is always 0. 
        public fun top_up_default_issuer_token_holder(
            issuer: &signer,
            holder: &mut AssetHolder<IssuerToken<DefaultToken>>,
            amount: u64,
        ) {
            // Issuer should be the holder's owner.
            assert(Signer::address_of(issuer) == holder.owner, 9000);
            // Top up amount should be positive.
            assert(amount > 0, 9000);
            
            IssuerToken::merge_issuer_token<DefaultToken>(
                &mut holder.asset,
                IssuerToken::mint_issuer_token<DefaultToken>(issuer,
                                                             0,
                                                             amount));
        }

        /// Adds Libra<CoinType> withdrawn from issuer's balance to the
        /// AssetHolder on issuer's account. 
        public fun top_up_libra_holder<CoinType>(
            issuer: &signer,
            holder: &mut AssetHolder<Libra<CoinType>>,
            amount: u64,
        ) {
            // Issuer should be the holder's owner.
            assert(Signer::address_of(issuer) == holder.owner, 9000);
            // Top up amount should be positive.
            assert(amount > 0, 9000);
            
            Libra::deposit<CoinType>(
                &mut holder.asset,
                LibraAccount::withdraw_libra(issuer, amount));
        }

        /// Takes IssuerToken<DefaultToken> from the AssetHolder and deposits
        /// on receivers account (stored in the IssuerTokenContainer struct).
        /// Note: For now, band for DefaultToken is always 0. 
        public fun deposit_default_issuer_token(
            receiver: &signer,
            holder: &mut AssetHolder<IssuerToken<DefaultToken>>,
            amount: u64,
        ) {
            // Deposit amount should be positive.
            assert(amount > 0, 9000);
            
            let issuer_tokens =
                IssuerToken::split_issuer_token<DefaultToken>(&mut holder.asset,
                                                              amount);

            // This call also asserts that receiver != issuer
            IssuerToken::deposit_issuer_token<DefaultToken>(receiver,
                                                            issuer_tokens);
        }

        /// Takes Libra<CoinType> from the AssetHolder and deposits on
        /// receivers account balance.
        public fun deposit_libra<CoinType>(
            receiver: &signer,
            holder: &mut AssetHolder<Libra<CoinType>>,
            amount: u64,
        ) {
            // Deposit amount should be positive.
            assert(amount > 0, 9000);
            
            let taken_libra = Libra::withdraw<CoinType>(&mut holder.asset,
                                                        amount);
            
            LibraAccount::deposit_libra<CoinType>(receiver,
                                                  holder.owner,
                                                  taken_libra);
        }
    }
    
}
