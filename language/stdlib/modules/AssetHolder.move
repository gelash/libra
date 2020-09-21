address 0x1 {

    module AssetHolder {
        use 0x1::Coin1::Coin1;
        use 0x1::Coin2::Coin2;
        use 0x1::Errors;
        use 0x1::LBR::LBR;
        use 0x1::Libra::{Self, Libra};
        use 0x1::LibraAccount;
        use 0x1::IssuerToken::{Self, IssuerToken};
        use 0x1::LibraTimestamp;
        use 0x1::Option::{Self, Option};
        use 0x1::Signer;
        use 0x1::TokenIssueCapability::{Self, TokenIssueCapability};

        /// Resource that is used for distributing IssuerTokens, but also knows
        /// how to distribute Libra. Should never be published directly to an
        /// account, as once loaded by Libra or IssuerTokens, it exposes public
        /// APIs for withdrawal. Instead, it should be wrapped inside the including
        /// module's native struct for access control (hence, the access control
        /// logic is by design detemined by the including module).
        resource struct AssetHolder<AssetType> {
            owner: address,

            /// TODO: when required, should become a map of id->AssetType, but not
            /// needed for the current TokenTypes (DefaultToken only uses band_id 0
            /// and MoneyOrderToken doesn't require holding actual IssuerTokens).
            asset: AssetType,

            /// Some TokenTypes, e.g. MoneyOrderToken, are assumed to be minted &
            /// available in an infinite amount, and as long as AssetWallet exists
            /// containing IssuerToken of such a TokenType specialization, any amount
            /// requested should be withdrawable from the AssetHolder. To implement
            /// such functionality (without making arbitrary minting possible), a
            /// capability created by the issuer should be wrapped inside the
            /// AssetHolder, and only with the Capability the IssuerTokens for a
            /// given account can be printed (if the caller is not the account).
            token_issue_capability: Option<TokenIssueCapability>,
        }

        /// Adding to non-issuer's AssetHolder.
        const ECANNOT_ADD_TO_OTHERS: u64 = 0;
        /// Adding a non-positive amount.
        const EADD_NON_POSITIVE: u64 = 1;
        /// Receiving a non-positive amount.
        const ERECEIVE_NON_POSITIVE: u64 = 2;
        
        /// Returns an AssetHolder holding IssuerToken<TokenType> with both band_id
        /// and amount 0. More complex constructors, when needed should be defined by
        /// the modules declaring individual TokenTypes (similar to how they all
        /// implement the logic for topping up or withdrawing from the assetholders).
        public fun zero_issuer_token_holder<TokenType>(
            issuer: &signer,
            issue_capability: bool,
        ): AssetHolder<IssuerToken<TokenType>> {
            if (issue_capability) {
                return AssetHolder<IssuerToken<TokenType>> {
                    owner: Signer::address_of(issuer),
                    asset: IssuerToken::mint_issuer_token<TokenType>(
                        issuer,
                        0,
                        0),
                    // Whoever has access to AssetWallet will now have capability
                    // to issue IssuerToken<MoneyOrderToken> (specialization id 1)
                    // in the issuer's name.
                    token_issue_capability: Option::some(
                        TokenIssueCapability::capability(issuer, 1))
                }
            };
            
            AssetHolder<IssuerToken<TokenType>> {
                owner: Signer::address_of(issuer),
                asset: IssuerToken::mint_issuer_token<TokenType>(
                    issuer,
                    0,
                    0),
                token_issue_capability: Option::none<TokenIssueCapability>(),
            }
        }

        /// This method is public so modules implementing token specializations
        /// (e.g. DefaultToken.move) can publish the structures on the libra root
        /// account during genesis (for type map tracking, CLI display, etc.).
        public fun publish_zero_issuer_token_holder<TokenType>(sender: &signer,
        ) {
            LibraTimestamp::assert_genesis();
            
            move_to(sender,
                    zero_issuer_token_holder<TokenType>(sender, false));
        }

        /// Returns the address of AssetHolder's owner, based on the owener field.
        public fun owner<TokenType>(holder: &AssetHolder<IssuerToken<TokenType>>,
        ): address {
            holder.owner
        }

        /// Returns mutable reference to the IssuerToken asset.
        public fun borrow_issuer_token_mut<TokenType>(
            holder: &mut AssetHolder<IssuerToken<TokenType>>,
        ): &mut IssuerToken<TokenType> {
            &mut holder.asset
        }

        /// Returns capability stored inside the holder, aborts if there is none.
        public fun borrow_capability<TokenType>(
            holder: &AssetHolder<IssuerToken<TokenType>>,
        ): &TokenIssueCapability {
            Option::borrow<TokenIssueCapability>(&holder.token_issue_capability)
        }

        /// Returns an AssetHolder holding Libra<CoinType> with 0 value.
        public fun zero_libra_holder<CoinType>(issuer: &signer
        ): AssetHolder<Libra<CoinType>> {
            AssetHolder<Libra<CoinType>> {
                owner: Signer::address_of(issuer),
                asset: Libra::zero<CoinType>(),
                token_issue_capability: Option::none<TokenIssueCapability>(),
                // token_issue capability is irrelevant here, set to none.
            }
        }
        
        /// Can only be called during genesis with libra root account.
        public fun initialize(lr_account: &signer) {
            LibraTimestamp::assert_genesis();

            // Publish for Libra types (IssuerToken types publish
            // in their initialize).
            move_to(lr_account, zero_libra_holder<Coin1>(lr_account));
            move_to(lr_account, zero_libra_holder<Coin2>(lr_account));
            move_to(lr_account, zero_libra_holder<LBR>(lr_account));
        }

        /// Adds Libra<CoinType> withdrawn from issuer's balance to the
        /// AssetHolder on issuer's account. 
        public fun top_up_libra_holder<CoinType>(
            issuer: &signer,
            holder: &mut AssetHolder<Libra<CoinType>>,
            amount: u64,
        ) {
            // Issuer should be the holder's owner.
            assert(Signer::address_of(issuer) == holder.owner,
                   Errors::invalid_argument(ECANNOT_ADD_TO_OTHERS));
            // Top up amount should be positive.
            assert(amount > 0,
                   Errors::invalid_argument(EADD_NON_POSITIVE));
            
            Libra::deposit<CoinType>(
                &mut holder.asset,
                LibraAccount::withdraw_libra(issuer, amount));
        }

        /// Takes Libra<CoinType> from the AssetHolder and deposits on
        /// receivers account balance.
        public fun receive_libra<CoinType>(
            receiver: &signer,
            holder: &mut AssetHolder<Libra<CoinType>>,
            amount: u64,
        ) {
            // Received amount should be positive.
            assert(amount > 0,
                   Errors::invalid_argument(ERECEIVE_NON_POSITIVE));
            
            let taken_libra = Libra::withdraw<CoinType>(&mut holder.asset,
                                                        amount);
            
            LibraAccount::deposit_libra<CoinType>(receiver,
                                                  holder.owner,
                                                  taken_libra);
        }
    }
    
}
