address 0x1 {

    module ShardedBitVector {
        use 0x1::LibraTimestamp;
        use 0x1::Option;
        use 0x1::Signer;
        use 0x1::Vector;        
        
        resource struct BitVectorBatch {
            // bit-packed, 0: redeemable, 1: deposited/canceled.
            // TODO: generalize bit-packing factor.
            boxed_bits: vector<u128>,

            // Expiration time of the batch (for recycling).
            expiration_time: u64,
        }

        resource struct BitVectorShard {
            // Address of the primary account for sharding.
            primary: address,

            // Batches of BitVector
            batches: vector<BitVectorBatch>,
        }

        resource struct BitVectorInfo {
            primary: address,

            // The vector of shard addresses is finalized.
            locked: bool,
            
            // Address of shards, in order.
            shards: vector<address>,
            num_shard_bits: vector<u64>,
        }

        public fun empty_info(sender: &signer
        ): BitVectorInfo {
            BitVectorInfo {
                primary: Signer::address_of(sender),

                locked: false,
                
                shards: Vector::empty(),
                // Size of this vector == number of batches
                num_shard_bits: Vector::empty(),
            }
        }

        fun empty_shard(primary_address: address
        ): BitVectorShard {
            BitVectorShard {
                primary: primary_address,
                batches: Vector::empty(),
            }
        }
                        
        public fun initialize(lr_account: &signer) {
            move_to(lr_account, empty_info(lr_account));
            move_to(lr_account, empty_shard(Signer::address_of(lr_account)));
        }
        
        public fun register_as_shard(sender: &signer,
                                     info: &mut BitVectorInfo,
        ) {
            assert(!info.locked, 9000);
            Vector::push_back(&mut info.shards, Signer::address_of(sender));

            move_to(sender, empty_shard(info.primary));
        }

        public fun lock_info(sender: &signer,
                             info: &mut BitVectorInfo,
        ) {
            assert(info.primary == Signer::address_of(sender), 9000);
            assert(!info.locked, 9000);
            info.locked = true;
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
        fun vector_with_copies(num_copies: u64, element: u128,
        ): vector<u128> {
            let ret = Vector::empty();
            let i = 0;
            while (i < num_copies) {
                Vector::push_back(&mut ret, element);
                i = i + 1;
            };

            ret
        }

        fun issue_batch_on_shard(shard_address: address,
                                 primary_address: address,
                                 batch_size: u64,
                                 duration_microseconds: u64,
        ): u64 acquires BitVectorShard {
            let shard = borrow_global_mut<BitVectorShard>(shard_address);
            assert(shard.primary == primary_address, 9000);

            let batch_id = Vector::length(&shard.batches);
            Vector::push_back(&mut shard.batches, BitVectorBatch {
                boxed_bits: vector_with_copies(div_ceil(batch_size, 128), 0),
                
                expiration_time: LibraTimestamp::now_microseconds() + duration_microseconds,
            });

            batch_id
        }
        
        public fun issue_batch(sender: &signer,
                               info: &mut BitVectorInfo,
                               batch_size: u64,
                               duration_microseconds: u64,
        ): u64 acquires BitVectorShard {
            let sender_address = Signer::address_of(sender);
            assert(info.primary == sender_address, 9000);
            assert(info.locked, 9000);

            let num_shards = Vector::length(&info.shards);
            let per_shard_bits = div_ceil(batch_size, num_shards);

            let batch_index = Vector::length(&info.num_shard_bits);
            Vector::push_back(&mut info.num_shard_bits, per_shard_bits);
            
            let i = 0;
            while (i < num_shards) {
                let shard_address = *Vector::borrow(&info.shards, i);
                let new_index = issue_batch_on_shard(shard_address,
                                                     sender_address,
                                                     per_shard_bits,
                                                     duration_microseconds);
                assert(batch_index == new_index, 9000);
                i = i + 1;
            };

            batch_index
        }

        // Set the bit to 1, return the previous value of the bit
        // (test-and-set semantics), or true if expired && !assert_expiry.
        fun test_and_set_bit_on_shard(shard_address: address,
                                      primary_address: address,
                                      batch_index: u64,
                                      bit_index: u64,
                                      assert_expiry: bool,
        ): bool acquires BitVectorShard {
            let shard = borrow_global_mut<BitVectorShard>(shard_address);
            assert(shard.primary == primary_address, 9000);

            let batch = Vector::borrow_mut(&mut shard.batches,
                                           batch_index);
            let was_expired = time_expired(batch.expiration_time);
            if (was_expired) {
                // If assert_expiry == true, we will assert.
                assert(!assert_expiry, 9000);
                // Otherwise, just return true (not set now).
                return true
            };
            
            // Not expired.
            let box_index = bit_index / 128;
            let pack_index = bit_index % 128;
            let bitmask = (1 << (pack_index as u8));
            let target_box = Vector::borrow_mut(&mut batch.boxed_bits, box_index);

            let test_status: bool = (*target_box & bitmask) == bitmask;
            *target_box = *target_box | bitmask;
            test_status
        }

        // Reason not everyone can call it is info! should be access controlled.
        public fun test_and_set_bit(info: &BitVectorInfo,
                                    batch_index: u64,
                                    bit_index: u64,
                                    assert_expiry: bool,
        ): bool acquires BitVectorShard {
            assert(info.locked, 9000);

            let per_shard_bits = *Vector::borrow(&info.num_shard_bits,
                                                 batch_index);
            let shard_index = bit_index / per_shard_bits;
            let shard_address = *Vector::borrow(&info.shards,
                                                shard_index);

            test_and_set_bit_on_shard(shard_address,
                                      info.primary,
                                      batch_index,
                                      bit_index % per_shard_bits,
                                      assert_expiry)
        }

        // TODO: get rid of when vector with copyable elements (non-resource types)
        // supports clearing.
        fun clear_vector(v: &mut vector<u128>,) {
            let length = Vector::length(v);

            let i = 0;
            while (i < length) {
                Vector::pop_back(v);
                i = i + 1;
            };
        }

        // Clear the status_array vector if the expiration time has passed and
        // return true if at least one status was cleared, otherwise return false.
        fun clear_bits_if_expired(bits_array: &mut vector<u128>,
                                  expiration_time: u64,
        ): bool {
            let expired = time_expired(expiration_time);

            let was_empty = Vector::is_empty(bits_array);
            if (expired) {
                clear_vector(bits_array);
            };

            expired && !was_empty
        }

        // If a batch has expired, clear its order statuses to save memory.
        // Return true if at least one status was cleared, otherwise return false.
        public fun compress_expired_batch_on_shard(shard_address: address,
                                                   primary_address: address,
                                                   batch_index: u64,
        ): bool acquires BitVectorShard {
            let shard = borrow_global_mut<BitVectorShard>(shard_address);
            assert(shard.primary == primary_address, 9000);
            
            let batch = Vector::borrow_mut(&mut shard.batches, batch_index);
            clear_bits_if_expired(&mut batch.boxed_bits,
                                  batch.expiration_time)
        }

        public fun compress_expired_batch(info: &BitVectorInfo,
                                          batch_index: u64,
        ): bool acquires BitVectorShard {
            assert(info.locked, 9000);

            let num_shards = Vector::length(&info.shards);

            let compressed = Option::none<bool>();
            let i = 0;
            while (i < num_shards) {
                let shard_address = *Vector::borrow(&info.shards, i);
                let i_compressed = compress_expired_batch_on_shard(shard_address,
                                                                   info.primary,
                                                                   batch_index);
                assert(Option::is_none(&compressed) ||
                       *Option::borrow(&compressed) == i_compressed, 9000);
                compressed = Option::some(i_compressed);

                i = i + 1;
            };

            *Option::borrow(&compressed)
        }
        
        // Iterates over all money order batches, and clears the status vector for
        // ones that have expired. Lightweight way to control/reduce the memory
        // footprint used by the MoneyOrders resource, if the issuer chooses to
        // batches the money orders with the same expiry time.
        public fun compress_expired_batches(info: &BitVectorInfo,
        ) acquires BitVectorShard {
            let num_batches = Vector::length(&info.num_shard_bits);
            
            let i = 0;
            while (i < num_batches) {
                compress_expired_batch(info, i);
                i = i + 1;
            };
        }

    }
    
}
