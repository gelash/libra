address 0x1 {

    module MoneyOrder {
        use 0x1::AssetHolder::{Self, AssetHolder};
        use 0x1::Coin1::Coin1;
        use 0x1::Coin2::Coin2;
        use 0x1::DefaultToken::{Self, DefaultToken};
        use 0x1::Event::{Self, EventHandle};
        use 0x1::Errors;
        use 0x1::IssuerToken::{Self, IssuerToken};
        use 0x1::LBR::LBR;
        use 0x1::Libra::Libra;
        use 0x1::LCS;
        use 0x1::LibraTimestamp;
        use 0x1::MoneyOrderToken::{Self, MoneyOrderToken};
        use 0x1::ShardedBitVectorBatches::{Self, BitVectorBatchesInfo};
        use 0x1::Signature;
        use 0x1::Signer;
        use 0x1::Vector;

        resource struct MoneyOrders {
            // Sharded storage of bit vectors.
            // 0: redeemable, 1: deposited/canceled.
            bit_vector_batches_info: BitVectorBatchesInfo,
            
            // Public key associated with the money orders, the issuing VASP holds
            // the corresponding private key.
            public_key: vector<u8>,

            // Event handle for issue event.
            issued_events: EventHandle<IssuedMoneyOrderEvent>,

            // Event handle for cancel event.
            canceled_events: EventHandle<CanceledMoneyOrderEvent>,

            // Event handle for redeem event.
            redeemed_events: EventHandle<RedeemedMoneyOrderEvent>,
        }

        /// Describes a money order: amount, type of asset, issuer, where to find the
        /// status bit (batch index and order_index within batch), and user_public_key.
        /// The issuing VASP creates user_public_key and user_secret_key pair for the
        /// user when preparing the money order.
        struct MoneyOrderDescriptor {
            /// The redeemable amount with the given money order.
            amount: u64,

            /// Type of asset with specific encoding, first 16 bits represent
            /// currency, (e.g. 0 = IssuerToken, 1 = Libra).
            asset_type_id: u8,
            /// Specializations (e.g. 0 = DefaultToken, 1 = MoneyOrderToken for
            /// IssuerToken and (0 = Coin1, 1 = Coin2, 2 = LBR for Libra).
            asset_specialization_id: u8,

            /// Address of the account that issued the given money order.
            issuer_address: address,
            /// Index of the batch among batches.
            batch_index: u64,
            /// Index among the money order status bits.
            order_index: u64,

            /// Issuer creates corresponding private key for the user.
            user_public_key: vector<u8>,
        }

        // Message for issued events.
        struct IssuedMoneyOrderEvent {
            batch_index: u64,
            num_orders: u64,
        }

        // Message for canceled events.
        struct CanceledMoneyOrderEvent {
            batch_index: u64,
            order_index: u64,
        }

        // Message for redeemed events.
        struct RedeemedMoneyOrderEvent {
            amount: u64,
            batch_index: u64,
            order_index: u64,
        }

        resource struct MoneyOrderAssetHolder<AssetType> {
            holder: AssetHolder<AssetType>,
        }

        /// Undefined type id for asset.
        const EUNDEFINED_ASSET_TYPE_ID: u64 = 0;
        /// Undefined specialization id for the asset type.
        const EUNDEFINED_SPECIALIZATION_ID: u64 = 1;
        /// Trying to top up AssetWallet<IssuerToken<MoneyOrderToken>>>, undefined
        const EMONEY_ORDER_TOKEN_TOP_UP: u64 = 2;
        /// Invalid issuer signature provided.
        const EINVALID_ISSUER_SIGNATURE: u64 = 3;
        /// Invalid user signature provided.
        const EINVALID_USER_SIGNATURE: u64 = 4;
        /// Depisiting an expired money order.
        const EMONEY_ORDER_EXPIRED: u64 = 5;
        /// Depositing a canceled or already deposited money order.
        const ECANT_DEPOSIT_MONEY_ORDER: u64 = 6;

        // Initializing money order asset holder for Libra<CoinType>.
        fun initialize_money_order_libra_holder<CoinType>(issuer: &signer,) {
            let issuer_address = Signer::address_of(issuer);
            if (!exists<MoneyOrderAssetHolder<Libra<CoinType>>>(
                issuer_address)) {
                move_to(issuer, MoneyOrderAssetHolder<Libra<CoinType>> {
                    holder: AssetHolder::zero_libra_holder<CoinType>(issuer),
                });
            };
        }

        // Initializing money order asset holder for IssuerToken<TokenType>.
        fun initialize_money_order_issuer_token_holder<TokenType>(
            issuer: &signer,
            issue_capability: bool,
        ) {
            let issuer_address = Signer::address_of(issuer);
            if (!exists<MoneyOrderAssetHolder<IssuerToken<TokenType>>>(
                issuer_address)) {
                move_to(issuer, MoneyOrderAssetHolder<IssuerToken<TokenType>> {
                    holder: AssetHolder::zero_issuer_token_holder<TokenType>(
                        issuer,
                        issue_capability,
                    ),
                });
            };
        }

        // Helper to assert that the asset type and specialization ids follow the
        // convention defined by the MoneyOrder module.
        fun assert_type_and_specialization_ids(type_id: u8,
                                               specialization_id: u8,
        ) {
            // TODO: make & test specific errors.
            assert(type_id >= 0 && type_id < 2,
                   Errors::invalid_argument(EUNDEFINED_ASSET_TYPE_ID));
            if (type_id == 0)
            {
                assert(specialization_id >= 0 && specialization_id < 2,
                       Errors::invalid_argument(EUNDEFINED_SPECIALIZATION_ID));

            } else if (type_id == 1)
            {
                assert(specialization_id >= 0 && specialization_id < 3,
                       Errors::invalid_argument(EUNDEFINED_SPECIALIZATION_ID));
            };
        }
        
        // Initialize money order asset holder. This has to happen on issuer's account
        // for any asset type, which issuer intends to issue money orders in. This
        // function is usually called by top_up_money_order_asset_holder, except
        // for IssuerToken<MoneyOrderToken>, for which its called from Money Order
        // initialization and will work without a call to top_up (topping up
        // IssuerToken<MoneyOrderToken> is not necessary and also not well-defined,
        // as it's assumed to be minted and available in infinite amount).
        fun initialize_money_order_asset_holder(issuer: &signer,
                                                asset_type_id: u8,
                                                asset_specialization_id: u8,
        ) {
            assert_type_and_specialization_ids(asset_type_id,
                                               asset_specialization_id);
            
            // TODO: here and below, consider passing type parameters and implying
            // the specialization ID's (for branching logic) by storing the mapping
            // on the issuer's account.
            if (asset_type_id == 0) {
                if (asset_specialization_id == 0) {
                    initialize_money_order_issuer_token_holder<DefaultToken>(
                        issuer,
                        false, // No capability to issue granted.
                    );
                } else if (asset_specialization_id == 1) {
                    initialize_money_order_issuer_token_holder<MoneyOrderToken>(
                        issuer,
                        true, // Capability to issue MoneyOrderTokens
                    );
                };
            } else if (asset_type_id == 1) {
                if (asset_specialization_id == 0) {
                    initialize_money_order_libra_holder<Coin1>(issuer);
                } else if (asset_specialization_id == 1) {
                    initialize_money_order_libra_holder<Coin2>(issuer);
                } else if (asset_specialization_id == 2) {
                    initialize_money_order_libra_holder<LBR>(issuer);
                };
            };
        }

        // Helper for topping up Libra<CoinType> balance of the issuer that can be
        // received by depositing a valid money order of the issuer.
        fun top_up_money_order_libra<CoinType>(issuer: &signer,
                                               top_up_amount: u64
        ) acquires MoneyOrderAssetHolder {
            let issuer_address = Signer::address_of(issuer);
            let mo_holder =
                borrow_global_mut<MoneyOrderAssetHolder<Libra<CoinType>>>(
                    issuer_address);
            
            AssetHolder::top_up_libra_holder<CoinType>(
                issuer,
                &mut mo_holder.holder,
                top_up_amount);
        }
        
        /// If it doesn't yet exist, initializes the asset holder for money orders -
        /// i.e. the structure where the receivers will deposit their money orders from.
        /// Then it adds top_up_amount of the specified asset to the money order
        /// asset holder. Money order asset holder is just a wrapper around AssetHolder
        /// that allows the MoneyOrder module to do access control on withdrawal,
        /// while AssetHolder & IssuerToken specializations have methods for dealing
        /// with different types of assets.
        /// 
        /// Note: mustn't be called for IssuerToken<MoneyOrderToken> (type_id 0,
        /// specialization_id 1), as that asset/specialization doesn't need topping up.
        public fun top_up_money_order_asset_holder(issuer: &signer,
                                                   asset_type_id: u8,
                                                   asset_specialization_id: u8,
                                                   top_up_amount: u64,
        ) acquires MoneyOrderAssetHolder {
            assert_type_and_specialization_ids(asset_type_id,
                                               asset_specialization_id);
            
            let issuer_address = Signer::address_of(issuer);
            
            initialize_money_order_asset_holder(issuer,
                                                asset_type_id,
                                                asset_specialization_id);
            if (asset_type_id == 0) {
                if (asset_specialization_id == 0) {
                    let mo_holder =
                        borrow_global_mut<MoneyOrderAssetHolder<IssuerToken<DefaultToken>>>(
                            issuer_address);
                
                    DefaultToken::asset_holder_top_up(
                        issuer,
                        &mut mo_holder.holder,
                        top_up_amount);
                };
                // No need to mint & top up MoneyOrderToken holder. This token type
                // assumes that infinite amount of each band has been minted and is
                // available - only controlled with the withdrawal access control.
                assert(asset_specialization_id != 1,
                       Errors::invalid_argument(EMONEY_ORDER_TOKEN_TOP_UP));
            } else if (asset_type_id == 1) {
                if (asset_specialization_id == 0) {
                    top_up_money_order_libra<Coin1>(issuer, top_up_amount);
                } else if (asset_specialization_id == 1) {
                    top_up_money_order_libra<Coin1>(issuer, top_up_amount);
                } else if (asset_specialization_id == 2) {
                    top_up_money_order_libra<LBR>(issuer, top_up_amount);
                };
            };
        }

        // Helper for receiving libra specializations from MoneyOrderAssetHolder.
        fun receive_money_order_libra<CoinType>(receiver: &signer,
                                                issuer_address: address,
                                                amount: u64
        ) acquires MoneyOrderAssetHolder {
            let mo_holder =
                borrow_global_mut<MoneyOrderAssetHolder<Libra<CoinType>>>(
                    issuer_address);

            AssetHolder::receive_libra<CoinType>(
                receiver,
                &mut mo_holder.holder,
                amount);
        }

        // Receive the specified asset type from MoneyOrderAssetHolder of the
        // money order issuer. Note: This function must be private, so the caller
        // does access control before calling.
        fun receive_from_issuer(receiver: &signer,
                                issuer_address: address,
                                asset_type_id: u8,
                                asset_specialization_id: u8,
                                batch_index: u64,
                                amount: u64
        ) acquires MoneyOrderAssetHolder {
            assert_type_and_specialization_ids(asset_type_id,
                                               asset_specialization_id);
            
            if (asset_type_id == 0) {
                if (asset_specialization_id == 0) {
                    let mo_holder =
                        borrow_global_mut<MoneyOrderAssetHolder<IssuerToken<DefaultToken>>>(
                            issuer_address);

                    DefaultToken::asset_holder_withdraw(receiver,
                                                        &mut mo_holder.holder,
                                                        amount);
                } else if (asset_specialization_id == 1) {
                    let mo_holder =
                        borrow_global_mut<MoneyOrderAssetHolder<IssuerToken<MoneyOrderToken>>>(
                            issuer_address);
                    
                    MoneyOrderToken::asset_holder_withdraw(receiver,
                                                           &mut mo_holder.holder,
                                                           batch_index,
                                                           amount);
                }
            } else if (asset_type_id == 1) {
                if (asset_specialization_id == 0) {
                    receive_money_order_libra<Coin1>(receiver, issuer_address, amount);
                } else if (asset_specialization_id == 1) {
                    receive_money_order_libra<Coin1>(receiver, issuer_address, amount);
                } else if (asset_specialization_id == 2) {
                    receive_money_order_libra<LBR>(receiver, issuer_address, amount);
                };
            };
        }

        // Default behavior when the account acts as a single shard for its own
        // storage of status bits.
        fun register_as_own_shard(issuer: &signer) acquires MoneyOrders {
            let orders = borrow_global_mut<MoneyOrders>(Signer::address_of(issuer));

            ShardedBitVectorBatches::register_as_shard(
                issuer,
                &mut orders.bit_vector_batches_info
            );
            ShardedBitVectorBatches::finish_shard_registration(
                issuer,
                &mut orders.bit_vector_batches_info
            );
        }
        
        /// Initialize the capability to issue money orders by publishing a MoneyOrders
        /// resource. MoneyOrderHolder
        public fun publish_money_orders(issuer: &signer,
                                        public_key: vector<u8>,
        ) acquires MoneyOrders {
            move_to(issuer, MoneyOrders {
                bit_vector_batches_info: ShardedBitVectorBatches::empty_info(
                    issuer,
                    50000, // Number of bits per shard, TODO: parametrize.
                ),
                public_key: public_key,
                issued_events: Event::new_event_handle<IssuedMoneyOrderEvent>(issuer),
                canceled_events: Event::new_event_handle<CanceledMoneyOrderEvent>(issuer),
                redeemed_events: Event::new_event_handle<RedeemedMoneyOrderEvent>(issuer),
            });

            // Register itself as a shard and conclude shard registration.
            // TODO: Pass a bool param for default (own shard) behavior. If false,
            // expose and use APIs for accounts to register as shards for money order
            // status storage. Adjust tests & benchmarks.
            register_as_own_shard(issuer);

            // Register IssuerToken specializations according to the convention that
            // the MoneyOrder module uses (consistent w. specialization ID's registered
            // on Libra_root account).
            IssuerToken::register_token_specialization<DefaultToken>(issuer, 0);
            IssuerToken::register_token_specialization<MoneyOrderToken>(issuer, 1);

            // Publish money order asset holder for IssuerToken<MoneyOrderToken>, only
            // for this specialization since it's designed for Money Orders and doesn't
            // need top-up (assumed that infinite amount is minted & available), hence
            // no need to call top-up for being able to use MoneyOrderTokens.
            initialize_money_order_asset_holder(issuer,
                                                0, // IssuerToken
                                                1, // MoneyOrderToken
            );
        }

        /// Can only be called during genesis with libra root account.
        public fun initialize(lr_account: &signer
        ) acquires MoneyOrders {
            LibraTimestamp::assert_genesis();
            
            // Initialize money order asset holder for all asset types.
            initialize_money_order_asset_holder(lr_account, 0, 0);
            initialize_money_order_asset_holder(lr_account, 0, 1);
            initialize_money_order_asset_holder(lr_account, 1, 0);
            initialize_money_order_asset_holder(lr_account, 1, 1);
            initialize_money_order_asset_holder(lr_account, 1, 2);
            
            // Publish MoneyOrders resource w. some fixed public key.
            publish_money_orders(lr_account,
                                 x"27274e2350dcddaa0398abdee291a1ac5d26ac83d9b1ce78200b9defaf2447c1");
        }

        // The only way to create a MoneyOrderDescriptor.
        public fun money_order_descriptor(
            _sender: &signer,
            amount: u64,
            asset_type_id: u8,
            asset_specialization_id: u8,
            issuer_address: address,
            batch_index: u64,
            order_index: u64,
            user_public_key: vector<u8>,
        ): MoneyOrderDescriptor {
            MoneyOrderDescriptor {
                amount: amount,
                asset_type_id: asset_type_id,
                asset_specialization_id: asset_specialization_id,
                issuer_address: issuer_address,
                batch_index: batch_index,
                order_index: order_index,
                user_public_key: user_public_key
            }
        }

        // Issue a batch of money orders, return batch index.
        public fun issue_money_order_batch(issuer: &signer,
                                           batch_size: u64,
                                           validity_microseconds: u64,
                                           grace_period_microseconds: u64,
        ) acquires MoneyOrders {
            let orders = borrow_global_mut<MoneyOrders>(Signer::address_of(issuer));
            let duration_microseconds = validity_microseconds + grace_period_microseconds;
            
            let batch_id = ShardedBitVectorBatches::issue_batch(
                issuer,
                &mut orders.bit_vector_batches_info,
                batch_size,
                duration_microseconds
            );

            Event::emit_event<IssuedMoneyOrderEvent>(
                &mut orders.issued_events,
                IssuedMoneyOrderEvent {
                    batch_index: batch_id,
                    num_orders: batch_size,
                }
            );
        }

        // Note: more complex general MO batching logic can be totally issuer-side.
        public fun issue_money_order(issuer: &signer,
                                     validity_microseconds: u64,
                                     grace_period_microseconds: u64,
        ) acquires MoneyOrders {
            issue_money_order_batch(issuer,
                                    1,
                                    validity_microseconds,
                                    grace_period_microseconds)
        }

        // Verifies the issuer signature for a money order descriptor.
        fun verify_issuer_signature(money_order_descriptor: MoneyOrderDescriptor,
                                    issuer_signature: vector<u8>,
        ) acquires MoneyOrders {
            let orders = borrow_global<MoneyOrders>(
                money_order_descriptor.issuer_address);

            let issuer_message = Vector::empty();
            Vector::append(&mut issuer_message, b"@@$$LIBRA_MONEY_ORDER_ISSUE$$@@");
            Vector::append(&mut issuer_message, LCS::to_bytes(&money_order_descriptor));

            assert(Signature::ed25519_verify(issuer_signature,
                                             *&orders.public_key,
                                             issuer_message),
                   Errors::invalid_argument(EINVALID_ISSUER_SIGNATURE));
        }

        // Verifies the receiver/user signature for a money order descriptor.
        fun verify_user_signature(receiver: &signer,
                                  money_order_descriptor: MoneyOrderDescriptor,
                                  user_signature: vector<u8>,
                                  domain_authenticator: vector<u8>,
        ) {
            let message = Vector::empty();
            Vector::append(&mut message, domain_authenticator);
            Vector::append(&mut message, LCS::to_bytes(&Signer::address_of(receiver)));
            Vector::append(&mut message, LCS::to_bytes(&money_order_descriptor));

            assert(Signature::ed25519_verify(user_signature,
                                             *&money_order_descriptor.user_public_key,
                                             *&message),
                   Errors::invalid_argument(EINVALID_USER_SIGNATURE));
        }


        // If the expiration time hasn't passed and the order bit was previously 0,
        // sets the order bit to 1 and returns true (i.e. cancelation changed state
        // and the observable redemption behavior), otherwise returns false.
        fun cancel_order(issuer_address: address,
                         batch_index: u64,
                         order_index: u64,
        ): bool acquires MoneyOrders {
            let orders = borrow_global_mut<MoneyOrders>(issuer_address);

            // The money order was canceled now if it wasn't expired, and if the
            // status bit wasn't 1 (e.g. already canceled or redeemed). We pass
            // assert_expiry = false, so the call returns 1 if expired or if the
            // bit was 1.
            let canceled_now = !ShardedBitVectorBatches::test_and_set_bit(
                &orders.bit_vector_batches_info,
                batch_index,
                order_index,
                false
            );
            
            if (canceled_now) {
                // Log a canceled event.
                Event::emit_event<CanceledMoneyOrderEvent>(
                    &mut orders.canceled_events,
                    CanceledMoneyOrderEvent {
                        batch_index: batch_index,
                        order_index: order_index,
                    }
                );
            };

            canceled_now
        }

        // Cancels a money order issued by the signer based on the batch index and
        // the status index. This has an affect that a MoneyOrderDescriptor pointing
        // to the same (batch_index, order_index) can ever be successfully redeemed.
        // If the call doesn't abort, returns true iff batch was not expired and the
        // order was not already canceled or deposited, o.w. false, meaning no change
        // in redeem behavior.
        //
        // Note: no need to check the signature as issuer is the authenticated caller,
        // and moreover, no need to provide a full MoneyOrderDescriptor since the
        // authenticated issuer owns the money orders and can cancel any money order,
        // e.g. even if the corresponding MoneyOrderDescriptor hasn't been prepared.
        //
        public fun issuer_cancel_money_order(issuer: &signer,
                                             batch_index: u64,
                                             order_index: u64,
        ): bool acquires MoneyOrders {
            cancel_order(Signer::address_of(issuer),
                         batch_index,
                         order_index)
        }

        // Deposit a money order from a user, prepared by sender
        // The money order issuer prepares the money_order_descriptor for a user off-chain
        // and signs it with the private key corresponding to its money orders (public
        // key published in the MoneyOrders resource).
        //
        // In order to deposit a money order, the receiving VASP:
        // 1. verifies the issuer's money order signature.
        // 2. signs [receiver_address, money_order_descriptor] on the user's behalf
        // using user_private_key (can't forge user_public_key w.o issuer) to obtain
        // user_signature
        // 3. submits a deposit request, containing issuer's message and signature,
        // plus the user_signature. Note that the receiver is the authenticated
        // author of the transaction.
        // TODO: think if this is enough.
        public fun deposit_money_order(receiver: &signer,
                                       money_order_descriptor: MoneyOrderDescriptor,
                                       issuer_signature: vector<u8>,
                                       user_signature: vector<u8>,
        ) acquires MoneyOrderAssetHolder, MoneyOrders {
            verify_user_signature(receiver,
                                  *&money_order_descriptor,
                                  user_signature,
                                  b"@@$$LIBRA_MONEY_ORDER_REDEEM$$@@");
            verify_issuer_signature(*&money_order_descriptor, issuer_signature);

            let issuer_address = money_order_descriptor.issuer_address;
            let orders = borrow_global_mut<MoneyOrders>(issuer_address);

            // Update the status bit, verify that it was 0.
            let bit_was_set = ShardedBitVectorBatches::test_and_set_bit(
                &mut orders.bit_vector_batches_info,
                money_order_descriptor.batch_index,
                money_order_descriptor.order_index,
                true
            );
            assert(!bit_was_set,
                   Errors::invalid_state(ECANT_DEPOSIT_MONEY_ORDER));

            // Actually withdraw the asset from issuer's account (AssetHolder) and
            // deposit to receiver's account (as determined by the convention
            // of the asset type, e.g. Libra will be deposited to Balance and
            // IssuerToken will be deposited to IssuerTokens).
            receive_from_issuer(receiver,
                                issuer_address,
                                money_order_descriptor.asset_type_id,
                                money_order_descriptor.asset_specialization_id,
                                money_order_descriptor.batch_index,
                                money_order_descriptor.amount);
            
             // Log a redeemed event.
            Event::emit_event<RedeemedMoneyOrderEvent>(
                &mut orders.redeemed_events,
                RedeemedMoneyOrderEvent {
                    amount: money_order_descriptor.amount,
                    batch_index: money_order_descriptor.batch_index,
                    order_index: money_order_descriptor.order_index,
                }
            );
        }

        // Money order cancellation by the receiver/user - doesn't redeem, just sets
        // the order status to 1, so it cannot be redeemed in the future. Returns true
        // iff batch was not expired and the order was not deposited, o.w. false.
        public fun cancel_money_order(receiver: &signer,
                                      money_order_descriptor: MoneyOrderDescriptor,
                                      issuer_signature: vector<u8>,
                                      user_signature: vector<u8>,
        ): bool acquires MoneyOrders {
            verify_user_signature(receiver,
                                  *&money_order_descriptor,
                                  user_signature,
                                  b"@@$$LIBRA_MONEY_ORDER_CANCEL$$@@");
            verify_issuer_signature(*&money_order_descriptor, issuer_signature);

            cancel_order(money_order_descriptor.issuer_address,
                         money_order_descriptor.batch_index,
                         money_order_descriptor.order_index)
        }

    }

}
