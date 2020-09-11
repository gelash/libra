// TODO: port to using move Errors
// 8001: money order expired
// 8002: signature did not verify (8010: issuer)
// 8003: money order already deposited or canceled
address 0x1 {

    module MoneyOrder {
        use 0x1::AssetHolder::{Self, AssetHolder};
        use 0x1::Coin1::Coin1;
        use 0x1::Coin2::Coin2;
        use 0x1::Event::{Self, EventHandle};
        use 0x1::IssuerToken::{IssuerToken, DefaultToken};
        use 0x1::LBR::LBR;
        use 0x1::Libra::Libra;
        use 0x1::LCS;
        use 0x1::LibraTimestamp;
        use 0x1::Signature;
        use 0x1::Signer;
        use 0x1::Vector;

        resource struct MoneyOrderBatch {
            // bit-packed, 0: redeemable, 1: deposited/canceled.
            order_status: vector<u8>,

            // Expiration time of these money orders.
            expiration_time: u64,
        }

        resource struct MoneyOrders {
            // Each batch has an expiry time and contains money order status bits.
            batches: vector<MoneyOrderBatch>,

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

        fun initialize_money_order_libra_holder<CoinType>(issuer: &signer,) {
            let issuer_address = Signer::address_of(issuer);
            if (!exists<MoneyOrderAssetHolder<Libra<CoinType>>>(
                issuer_address)) {
                move_to(issuer, MoneyOrderAssetHolder<Libra<CoinType>> {
                    holder: AssetHolder::create_libra_holder<CoinType>(issuer),
                });
            };
        }
        
        fun initialize_money_order_asset_holder(issuer: &signer,
                                                asset_type_id: u8,
                                                asset_specialization_id: u8,
        ) {
            let issuer_address = Signer::address_of(issuer);
            if (asset_type_id == 0) {
                if (!exists<MoneyOrderAssetHolder<IssuerToken<DefaultToken>>>(
                    issuer_address)) {
                    if (asset_specialization_id == 0) {
                        move_to(issuer, MoneyOrderAssetHolder<IssuerToken<DefaultToken>> {
                            holder: AssetHolder::create_default_issuer_token_holder(issuer),
                        });
                    };
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
        /// i.e. the structure where the receivers will redeem their money orders from.
        /// Then it adds top_up_amount of the specified asset to the money order
        /// asset holder. Money order asset holder is just a wrapper around AssetHolder
        /// that allows the MoneyOrder module to do access control on withdrawal,
        /// while AssetHolder has methods to deal with different assets.
        /// Asset_type_id and asset_specialization_id determine the store asset
        /// (e.g. whether it's Libra<Coin1>, IssuerToken<DefaultToken>, or some other
        /// type or specialization). 
        public fun top_up_money_order_asset_holder(issuer: &signer,
                                                   asset_type_id: u8,
                                                   asset_specialization_id: u8,
                                                   top_up_amount: u64,
        ) acquires MoneyOrderAssetHolder {
            let issuer_address = Signer::address_of(issuer);
            
            initialize_money_order_asset_holder(issuer,
                                                asset_type_id,
                                                asset_specialization_id);
            
            // TODO: This dispatching itself can't be moved to AssetHolder because
            // the fact that AssetHolder APIs are called from MoneyOrders module
            // provides access control. TODO: However, the mapping from type_id to
            // the function calls for creation, loading & depositing assets maybe
            // could be re-used if language allows.
            if (asset_type_id == 0) {
                if (asset_specialization_id == 0) {
                    let mo_holder =
                        borrow_global_mut<MoneyOrderAssetHolder<IssuerToken<DefaultToken>>>(
                            issuer_address);
                
                    AssetHolder::top_up_default_issuer_token_holder(
                        issuer,
                        &mut mo_holder.holder,
                        top_up_amount);
                };
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

        fun deposit_money_order_libra<CoinType>(receiver: &signer,
                                                issuer_address: address,
                                                amount: u64
        ) acquires MoneyOrderAssetHolder {
            let mo_holder =
                borrow_global_mut<MoneyOrderAssetHolder<Libra<CoinType>>>(
                    issuer_address);

            AssetHolder::deposit_libra<CoinType>(
                receiver,
                &mut mo_holder.holder,
                amount);
        }
                
        // This function must be private, so the caller does access control.
        fun deposit_from_issuer(receiver: &signer,
                                issuer_address: address,
                                asset_type_id: u8,
                                asset_specialization_id: u8,
                                amount: u64
        ) acquires MoneyOrderAssetHolder {
            if (asset_type_id == 0) {
                if (asset_specialization_id == 0) {
                    let mo_holder =
                        borrow_global_mut<MoneyOrderAssetHolder<IssuerToken<DefaultToken>>>(
                            issuer_address);

                    AssetHolder::deposit_default_issuer_token(receiver,
                                                              &mut mo_holder.holder,
                                                              amount);
                };
            } else if (asset_type_id == 1) {
                if (asset_specialization_id == 0) {
                    deposit_money_order_libra<Coin1>(receiver, issuer_address, amount);
                } else if (asset_specialization_id == 1) {
                    deposit_money_order_libra<Coin1>(receiver, issuer_address, amount);
                } else if (asset_specialization_id == 2) {
                    deposit_money_order_libra<LBR>(receiver, issuer_address, amount);
                };
            };
        }

        /// Initialize the capability to issue money orders by publishing a MoneyOrders
        /// resource. MoneyOrderHolder
        public fun publish_money_orders(issuer: &signer,
                                        public_key: vector<u8>,
        ) {
            move_to(issuer, MoneyOrders {
                batches: Vector::empty(),
                public_key: public_key,
                issued_events: Event::new_event_handle<IssuedMoneyOrderEvent>(issuer),
                canceled_events: Event::new_event_handle<CanceledMoneyOrderEvent>(issuer),
                redeemed_events: Event::new_event_handle<RedeemedMoneyOrderEvent>(issuer),
            });
        }

        /// Can only be called during genesis with libra root account.
        public fun initialize(lr_account: &signer
        ) {
            LibraTimestamp::assert_genesis();

            // Initialize money order asset holder for all asset type ids.
            initialize_money_order_asset_holder(lr_account, 0, 0);
            
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


        // Checks whether a particular expiration time has passed.
        fun time_expired(expiration_time: u64): bool {
            LibraTimestamp::now_microseconds() >= expiration_time
        }

        // TODO: get rid when standard supports.
        fun div_ceil(a: u64, b: u64,
        ): u64 {
            (a + b - 1) / b
        }

        // TODO: get rid if and when vector supports initializers for copyable
        // elements (templated on the type?).
        fun vector_with_copies(num_copies: u64, element: u8,
        ): vector<u8> {
            let ret = Vector::empty();
            let i = 0;
            while (i < num_copies) {
                Vector::push_back(&mut ret, element);
                i = i + 1;
            };

            ret
        }

        // Issue a batch of money orders, return batch index.
        public fun issue_money_order_batch(issuer: &signer,
                                           batch_size: u64,
                                           validity_microseconds: u64,
                                           grace_period_microseconds: u64,
        ) acquires MoneyOrders {
            let status = vector_with_copies(div_ceil(batch_size, 8), 0);

            let orders = borrow_global_mut<MoneyOrders>(Signer::address_of(issuer));
            let duration_microseconds = validity_microseconds + grace_period_microseconds;

            let batch_id = Vector::length(&orders.batches);
            Vector::push_back(&mut orders.batches, MoneyOrderBatch {
                order_status: status,
                expiration_time: LibraTimestamp::now_microseconds() + duration_microseconds,
            });

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
                   8010);
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
                   8002);
        }

        // Set the bit corresponding to an order status to 1 (deposited/canceled).
        // Return the previous value of the bit (test-and-set semantics).
        fun test_and_set_order_status(status_array: &mut vector<u8>,
                                      order_index: u64,
        ): bool {
            let byte_index = order_index / 8;
            let bit_index = order_index % 8;
            let bitmask = (1 << (bit_index as u8));
            let target_byte = Vector::borrow_mut(status_array, byte_index);

            let test_status: bool = (*target_byte & bitmask) == bitmask;
            *target_byte = *target_byte | bitmask;
            test_status
        }

        // If the expiration time hasn't passed and the order bit was previously 0,
        // sets the order bit to 1 and returns true (i.e. cancelation changed state
        // and the observable redemption behavior), otherwise returns false.
        fun cancel_order_impl(issuer_address: address,
                              batch_index: u64,
                              order_index: u64,
        ): bool acquires MoneyOrders {
            let orders = borrow_global_mut<MoneyOrders>(issuer_address);
            let order_batch = Vector::borrow_mut(&mut orders.batches, batch_index);

            let was_expired = time_expired(order_batch.expiration_time);

            // The money order was canceled now if it wasn't expired, and if the
            // status bit wasn't 1 (e.g. already canceled or redeemed). Note: If
            // expired, don't set the bit since the order_status array may be cleared.
            let canceled_now = !(was_expired ||
                                 test_and_set_order_status(&mut order_batch.order_status,
                                                           order_index));

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
            cancel_order_impl(Signer::address_of(issuer),
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
            let order_batch = Vector::borrow_mut(&mut orders.batches,
                                                 money_order_descriptor.batch_index);

            // Verify that money order is not expired.
            assert(!time_expired(order_batch.expiration_time), 8001);

            // Update the status bit, verify that it was 0.
            assert(!test_and_set_order_status(&mut order_batch.order_status,
                                             money_order_descriptor.order_index), 8003);

            // Actually withdraw the asset from issuer's account (AssetHolder) and
            // deposit to receiver's account (as determined by the convention
            // of the asset type, e.g. Libra will be deposited to Balance and
            // IssuerToken will be deposited to IssuerTokens).
            deposit_from_issuer(receiver,
                                issuer_address,
                                0, // TODO: generalize
                                0, // TODO: generalize
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

            cancel_order_impl(money_order_descriptor.issuer_address,
                              money_order_descriptor.batch_index,
                              money_order_descriptor.order_index)
        }

        // TODO: get rid of when vector with copyable elements (non-resource types)
        // supports clearing.
        fun clear_vector(v: &mut vector<u8>,) {
            let length = Vector::length(v);

            let i = 0;
            while (i < length) {
                Vector::pop_back(v);
                i = i + 1;
            };
        }

        // Clear the status_array vector if the expiration time has passed and
        // return true if at least one status was cleared, otherwise return false.
        fun clear_statuses_if_expired(status_array: &mut vector<u8>,
                                      expiration_time: u64,
        ): bool {
            let expired = time_expired(expiration_time);

            let was_empty = Vector::is_empty(status_array);
            if (expired) {
                clear_vector(status_array);
            };

            expired && !was_empty
        }

        // If a batch has expired, clear its order statuses to save memory.
        // Return true if at least one status was cleared, otherwise return false.
        public fun compress_expired_batch(issuer: &signer,
                                          batch_index: u64,
        ): bool acquires MoneyOrders {
            let orders = borrow_global_mut<MoneyOrders>(Signer::address_of(issuer));
            let batch = Vector::borrow_mut(&mut orders.batches, batch_index);

            clear_statuses_if_expired(&mut batch.order_status,
                                      batch.expiration_time)
        }

        // Iterates over all money order batches, and clears the status vector for
        // ones that have expired. Lightweight way to control/reduce the memory
        // footprint used by the MoneyOrders resource, if the issuer chooses to
        // batches the money orders with the same expiry time.
        public fun compress_expired_batches(issuer: &signer
        ) acquires MoneyOrders {
            let orders = borrow_global_mut<MoneyOrders>(Signer::address_of(issuer));

            let i = 0;
            while (i < Vector::length(&orders.batches)) {
                let batch = Vector::borrow_mut(&mut orders.batches, i);
                clear_statuses_if_expired(&mut batch.order_status,
                                          batch.expiration_time);
                i = i + 1;
            };
        }
    }

}
