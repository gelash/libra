// 8001 - money order expired
// 8002 - signature did not verify
// 8003 - money order already deposited
// 8004 - insufficient balance on issuer's account
// 8005 - issuer address mismatch
address 0x1 {

    module MoneyOrder {
        use 0x1::Vector;
        use 0x1::LCS;
        use 0x1::LibraTimestamp;
        use 0x1::Signature;
        use 0x1::Signer;

        // TODO: decide exactly what should be a resource among these structs below.
        // TODO: switch to Libra<MoneyOrderCoin> when that's allowed.
        resource struct MoneyOrderCoin {
            amount: u64,
        }

        resource struct MoneyOrderBatch {
            // bit-packed, 0: unused, 1: deposited.
            order_status: vector<u8>,
            
            // Expiration time of these money orders.
            expiration_time: u64,
        }

        resource struct MoneyOrders {
            // We currently store money orders in batches. Instead of a single, ever-growing
            // data-structure of money orders - instead, we want to be able to clean-up
            // or at least not store/synchronize the status bits for money orders that are
            // no longer relevant (e.g. expired, deposited). Batching is a simple mechanism
            // that accomplishes this as every batch has an associated expiry time.
            batches: vector<MoneyOrderBatch>,

            // Public key associated with the money orders, the issuing VASPs will hold
            // the corresponding private key.
            public_key: vector<u8>,

            // Money orders will be fulfilled from this balance.
            balance: MoneyOrderCoin,
        }

        // Describes a money order: amount, issuer, where to find the status bit
        // (batch index and order_index within batch), and user_public_key. The issuing
        // VASP creates user_public_key and user_secret_key pair for the user when
        // preparing the money order.
        struct MoneyOrderDescriptor {
            // The amount of MoneyOrderCoin redeemable with the money order.
            amount: u64,
            
            issuer: address,
            // Index of the batch among batches.
            batch_index: u64,
            // Index among the money order status bits.
            order_index: u64,

            // Issuer creates corresponding private key for the user.
            user_public_key: vector<u8>,
        }

        // Initialize the capability to issue money orders by publishing a MoneyOrders.
        public fun initialize_money_orders(issuer: &signer,
                                           public_key: vector<u8>,
                                           starting_balance: MoneyOrderCoin,
        ) {
            move_to(issuer, MoneyOrders {
                batches: Vector::empty(),
                public_key: public_key,
                balance: starting_balance,
            });
        }

        // TODO: get rid when standard supports.
        fun div_ceil(a: u64, b: u64,
        ): u64 {
            (a + b - 1) / b
        }
        
        // Issue a batch of money orders, return batch index.
        public fun issue_money_order_batch(issuer: &signer,
                                           batch_size: u64,
                                           validity_microseconds: u64,
        ): u64 acquires MoneyOrders {
            let status = Vector::empty();
            let i = 0;
            while (i < div_ceil(batch_size, 8)) {
                Vector::push_back(&mut status, 0);
                i = i + 1;
            };

            let orders = borrow_global_mut<MoneyOrders>(Signer::address_of(issuer));
            Vector::push_back(&mut orders.batches, MoneyOrderBatch {
                order_status: status,
                expiration_time: LibraTimestamp::now_microseconds() + validity_microseconds,
            });

            Vector::length(&orders.batches)
        }

        // Note: more complex general MO batching logic can be totally issuer-side.
        public fun issue_money_order(issuer: &signer,
                                     validity_microseconds: u64,
        ): u64 acquires MoneyOrders {
            issue_money_order_batch(issuer, 1, validity_microseconds)
        }

        // Verifies the issuer signature for a money order descriptor.
        fun verify_issuer_signature(money_order_descriptor: MoneyOrderDescriptor,
                                    issuer_signature: vector<u8>,
        ) acquires MoneyOrders {
            let orders = borrow_global<MoneyOrders>(money_order_descriptor.issuer);
            
            let issuer_message = Vector::empty();
            Vector::append(&mut issuer_message, b"@@$$LIBRA_MONEY_ORDER_ISSUE$$@@");
            Vector::append(&mut issuer_message, LCS::to_bytes(&money_order_descriptor));
            assert(Signature::ed25519_verify(issuer_signature,
                                             *&orders.public_key,
                                             issuer_message),
                   8002);
        }

        // Verifies the receiver/user signature for a money order descriptor.
        fun verify_user_signature(receiver: &signer,
                                  money_order_descriptor: MoneyOrderDescriptor,
                                  user_signature: vector<u8>,
        ) {
            let message = Vector::empty();
            Vector::append(&mut message, b"@@$$LIBRA_MONEY_ORDER_REDEEM$$@@");
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

            let test_status: bool = (*target_byte & bitmask) == 0;
            *target_byte = *target_byte | bitmask;
            test_status
        }

        // Sets the order bit to 1, returns true if the expiration time hasn't passed
        // and the order bit was previously 0 - i.e. if cancelation actually changed
        // observable redemption behavior.
        fun cancel_order_impl(money_order_descriptor: &MoneyOrderDescriptor
        ): bool acquires MoneyOrders {
            let orders = borrow_global_mut<MoneyOrders>(money_order_descriptor.issuer);
            let order_batch = Vector::borrow_mut(&mut orders.batches,
                                                 money_order_descriptor.batch_index);
            
            let was_expired =
                LibraTimestamp::now_microseconds() > order_batch.expiration_time;
            let prev_status =
                test_and_set_order_status(&mut order_batch.order_status,
                                          money_order_descriptor.order_index);
            !(was_expired || prev_status)
        }
        
        // Cancels a money described by MoneyOrderDescriptor order issued by the issuer.
        // Note: no need to check the signature as issuer is the authenticated caller.
        // If the call doesn't abort, returns true iff batch was not expired and the
        // order was not deposited, o.w. false, meaning no change in redeem behavior.
        public fun issuer_cancel_money_order(issuer: &signer,
                                             money_order_descriptor: MoneyOrderDescriptor,
        ): bool acquires MoneyOrders {
            assert(Signer::address_of(issuer) == money_order_descriptor.issuer, 8005);
            cancel_order_impl(&money_order_descriptor)
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
        public fun redeem_money_order(receiver: &signer,
                                      money_order_descriptor: MoneyOrderDescriptor,
                                      issuer_signature: vector<u8>,
                                      user_signature: vector<u8>,
        ): MoneyOrderCoin acquires MoneyOrders {
            verify_user_signature(receiver, *&money_order_descriptor, user_signature);
            verify_issuer_signature(*&money_order_descriptor, issuer_signature);
            
            let orders = borrow_global_mut<MoneyOrders>(money_order_descriptor.issuer);
            let order_batch = Vector::borrow_mut(&mut orders.batches,
                                                 money_order_descriptor.batch_index);
            // Verify that money order is not expired
            assert(LibraTimestamp::now_microseconds() < order_batch.expiration_time,
                   8001);
            // Update the status bit, verify that it was 0.
            assert(!test_and_set_order_status(&mut order_batch.order_status,
                                             money_order_descriptor.order_index), 8003);

            // Actually withdraw the coins from issuer's account.
            let issuer_coin_value = &mut orders.balance.amount;
            assert(*issuer_coin_value >= money_order_descriptor.amount, 8004);
            *issuer_coin_value = *issuer_coin_value - money_order_descriptor.amount;
            MoneyOrderCoin {
                amount: money_order_descriptor.amount,
            }
        }

        public fun deposit_money_order(receiver: &signer,
                                       money_order_descriptor: MoneyOrderDescriptor,
                                       issuer_signature: vector<u8>,
                                       user_signature: vector<u8>,
        ) acquires MoneyOrderCoin, MoneyOrders {
            let MoneyOrderCoin { amount } = redeem_money_order(receiver,
                                                              money_order_descriptor,
                                                              issuer_signature,
                                                              user_signature);
            
            let receiver_coins = borrow_global_mut<MoneyOrderCoin>(
                Signer::address_of(receiver));
            let receiver_coin_value = &mut receiver_coins.amount;
            *receiver_coin_value = *receiver_coin_value + amount;
            // TODO: Figure out if we need to return an event on success.
        }

        // Money order cancellation by the receiver/user - doesn't redeem, just sets
        // the order status to 1, so it cannot be redeemed in the future. Returns true
        // iff batch was not expired and the order was not deposited, o.w. false.  
        public fun cancel_money_order(receiver: &signer,
                                      money_order_descriptor: MoneyOrderDescriptor,
                                      issuer_signature: vector<u8>,
                                      user_signature: vector<u8>,
        ): bool acquires MoneyOrders {
            verify_user_signature(receiver, *&money_order_descriptor, user_signature);
            verify_issuer_signature(*&money_order_descriptor, issuer_signature);

            cancel_order_impl(&money_order_descriptor)
        }

        // TODO: More interfaces, e.g. clean-up (index, or prefix), balance top-up.
    }
    
}
