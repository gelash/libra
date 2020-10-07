address 0x1 {

    module ShardedBitVectorBatches {
        use 0x1::LibraTimestamp;
        use 0x1::Option;
        use 0x1::Signer;
        use 0x1::Vector;        

        /// A resouce that contains actual bits stored on a shard per batch.
        resource struct BitVectorBatch {
            /// bit-packed. TODO: generalize bit-packing factor.
            stored_bits: vector<u128>,

            /// Expiration time of the batch (for recycling).
            expiration_time: u64,
        }

        /// A resource contains meta-data for each shard and a vector
        /// pointing to BitVectorBatch for each batch. A shard currently is
        /// dedicated to a single ShardedBitVectorBatches data-structure, i.e.
        /// it can't store parts of two different shared bit vectors.
        resource struct BitVectorBatchesShard {
            /// Address of the primary account for sharding.
            /// Primary can also be one of its shards.
            primary: address,

            /// Batches of a bit vector stored on the given shard.
            batch_store: vector<BitVectorBatch>,
        }

        /// A resource containing meta-data for a SharedBitVectorBatches
        /// data-structure.
        resource struct BitVectorBatchesInfo {
            /// The address of the primary account for the
            /// ShardedBitVectorBatches data-structure. Info should be
            /// published on primary's account.
            primary: address,

            /// The vector of shard addresses is finalized. Before finalized,
            /// the ShardedBitVectorBatches storage cannot be used, and once
            /// finalized, new shards can no longer be registered.
            locked: bool,
            
            /// Addresses of the shards, in order. Note: Primary can also
            /// register its address as one of the shards.
            shards: vector<address>,
            /// Number of bits stored per shard per batch. Once a shard stores
            /// num_bits_per_shard bits, the next shard stores next bits.
            /// The last shard stores as many bits as necessary. Formally,
            /// the invariant is that only the last shard can store
            /// >num_bits_per_shard bits, other shards always store
            /// <= num_bits_per_shard bits, and if a shard stores
            /// <num_bits_per_shard bits, then all previous shards must be
            /// storing exactly =num_bits_per_shard bits and all later shards
            /// must store 0 bits.
            num_bits_per_shard: u64,
            /// Number of total bits in a batch, length of the vector is
            /// equal to the number of batches.
            batch_total_bits: vector<u64>,
        }

        /// Returns an empty BitVectorBatchInfo resource, to be published on the
        /// primary account address.
        public fun empty_info(sender: &signer,
                              max_bits_per_shard: u64,
        ): BitVectorBatchesInfo {
            BitVectorBatchesInfo {
                primary: Signer::address_of(sender),

                locked: false,
                
                shards: Vector::empty(),
                num_bits_per_shard: max_bits_per_shard,
                batch_total_bits: Vector::empty(),
            }
        }

        /// Returns an empty per-shard bit vector storage. To be published
        /// on each shard's account address (possibly on primary's account
        /// address as well if it is registered as a shard itself).
        fun empty_shard(primary_address: address
        ): BitVectorBatchesShard {
            BitVectorBatchesShard {
                primary: primary_address,
                batch_store: Vector::empty(),
            }
        }

        /// Can only be called during genesis with libra root account.
        public fun initialize(lr_account: &signer) {
            LibraTimestamp::assert_genesis();

            // Initialize empty resource types.
            move_to(lr_account, empty_info(lr_account, 1000));
            // TODO: bring back when publish_money_orders doesn't by default
            // register itself as shard (TODO in MoneyOrder module) - right now
            // it does leading to a genesis abort w. RESOURCE_ALREADY_EXISTS.
            // move_to(lr_account, empty_shard(Signer::address_of(lr_account)));
        }

        /// An account calls this function to be registered as a shard on
        /// a BitVectorBatches storage corresponding to the provided info (info
        /// determines the primary). Registration is only possible while
        /// locked = false, otherwise an assert is triggered.
        public fun register_as_shard(sender: &signer,
                                     info: &mut BitVectorBatchesInfo,
        ) {
            // Assert that registration hasn't already concluded.
            assert(!info.locked, 9000);

            let shard_address = Signer::address_of(sender);
            // Ensure that shard is not already registered - registering the
            // same account twice is not possible.
            assert(!Vector::contains(&info.shards, &shard_address), 9000);
            Vector::push_back(&mut info.shards, shard_address);

            // This can still fail if the shard is registered for another
            // info. If we would like to enable same account to serve as
            // shard for multiple BitVectorBatches data-structures, we need
            // the way to distinguish the shard types - i.e. for instance
            // by using (if it was available) an Address/Int to type paradigm.
            // Note: a native implementation that internally manages *dedicated*
            // data/shard accounts wouldn't have this problem.
            move_to(sender, empty_shard(info.primary));
        }

        /// Locks the info to conclude the shard registration, can only
        /// be called by the primary.
        public fun finish_shard_registration(sender: &signer,
                                             info: &mut BitVectorBatchesInfo,
        ) {
            assert(info.primary == Signer::address_of(sender), 9000);

            assert(!info.locked, 9000);
            info.locked = true;
        }

        // Checks whether a given expiration time has passed.
        fun time_expired(expiration_time: u64): bool {
            LibraTimestamp::now_microseconds() >= expiration_time
        }

        // TODO: get rid when standard supports.
        fun div_ceil(a: u64, b: u64,
        ): u64 {
            (a + b - 1) / b
        }

        // Issue a (corresponding part of the whole) batch on a given shard.
        fun issue_batch_on_shard(shard_address: address,
                                 primary_address: address,
                                 num_bits: u64,
                                 duration_microseconds: u64,
        ): u64 acquires BitVectorBatchesShard {
            // Note: if shards were allowed to be shared (currently dedicated)
            // then this would require identifying the correct one (as a
            // specialization of BitVectorBatchesShard.
            let shard = borrow_global_mut<BitVectorBatchesShard>(shard_address);
            assert(shard.primary == primary_address, 9000);

            let batch_id = Vector::length(&shard.batch_store);
            Vector::push_back(&mut shard.batch_store, BitVectorBatch {
                stored_bits: Vector::initialize(0, div_ceil(num_bits, 128)),
                
                expiration_time: LibraTimestamp::now_microseconds() +
                    duration_microseconds,
            });

            batch_id
        }

        // TODO: get rid of when global utility for min is available.
        fun min(a: u64, b: u64): u64 {
            if (a < b) {
                return a
            };
            
            b
        }
        
        /// Issue a batch on the sharded BitVectorBatches storage corresponding
        /// to the provided info. Can only be called by the primary.
        public fun issue_batch(sender: &signer,
                               info: &mut BitVectorBatchesInfo,
                               batch_size_bits: u64,
                               duration_microseconds: u64,
        ): u64 acquires BitVectorBatchesShard {
            let sender_address = Signer::address_of(sender);
            assert(info.primary == sender_address, 9000);

            // Assert that shard registration has concluded.
            assert(info.locked, 9000);

            let batch_index = Vector::length(&info.batch_total_bits);
            Vector::push_back(&mut info.batch_total_bits, batch_size_bits);

            let num_shards = Vector::length(&info.shards);
            let bits_to_store = batch_size_bits;             
            let i = 0;
            while (i < num_shards && bits_to_store > 0) {
                let shard_address = *Vector::borrow(&info.shards, i);

                let num_bits_on_shard =
                    min(info.num_bits_per_shard,
                        bits_to_store);
                if (i == num_shards - 1) {
                    // Last shard must store all remaining bits in the batch.
                    num_bits_on_shard = bits_to_store;
                };
                
                let new_index = issue_batch_on_shard(shard_address,
                                                     sender_address,
                                                     num_bits_on_shard,
                                                     duration_microseconds);
                // Assert the batch_index is consistent on shard's storage.
                assert(batch_index == new_index, 9000);

                bits_to_store = bits_to_store - num_bits_on_shard;
                i = i + 1;
            };

            batch_index
        }

        // If unexpired, set the bit to 1 & return the previous value of the bit
        // (test-and-set semantics). When expired, either assert or return
        // true if assert_expiry == false (consistent with the bit not being set
        // by this call, i.e. being already set, in the non-expired case).
        fun test_and_set_bit_on_shard(shard_address: address,
                                      primary_address: address,
                                      batch_index: u64,
                                      bit_index: u64,
                                      assert_expiry: bool,
        ): bool acquires BitVectorBatchesShard {
            let shard = borrow_global_mut<BitVectorBatchesShard>(shard_address);
            assert(shard.primary == primary_address, 9000);

            let batch = Vector::borrow_mut(&mut shard.batch_store,
                                           batch_index);
            let was_expired = time_expired(batch.expiration_time);
            if (was_expired) {
                // If assert_expiry == true, we will assert.
                assert(!assert_expiry, 9000);
                // Otherwise, just return true (not set now).
                return true
            };
            
            // Not expired.
            let store_index = bit_index / 128;
            let packed_index = bit_index % 128;
            let bitmask = (1 << (packed_index as u8));
            let target_store = Vector::borrow_mut(&mut batch.stored_bits,
                                                  store_index);

            let test_status: bool = (*target_store & bitmask) == bitmask;
            *target_store = *target_store | bitmask;
            test_status
        }

        /// Function that tests and sets a bit specified by the batch and index
        /// with the batch in the ShardedBitVectorBatches data-structure
        /// corresponding to the info. The function is public without signer,
        /// and the access control is the responsibility of the info holder.
        public fun test_and_set_bit(info: &BitVectorBatchesInfo,
                                    batch_index: u64,
                                    bit_index: u64,
                                    assert_expiry: bool,
        ): bool acquires BitVectorBatchesShard {
            assert(info.locked, 9000);

            let num_shards = Vector::length(&info.shards);
            
            let shard_index = bit_index / info.num_bits_per_shard;
            let bit_index_on_shard = bit_index % info.num_bits_per_shard;
            if (shard_index >= num_shards) {
                // The last shard contains all remaining bits in every batch.
                shard_index = num_shards - 1;
                bit_index_on_shard =
                    bit_index - (num_shards - 1) * info.num_bits_per_shard;
            };
            
            let shard_address = *Vector::borrow(&info.shards,
                                                shard_index);
            test_and_set_bit_on_shard(shard_address,
                                      info.primary,
                                      batch_index,
                                      bit_index_on_shard,
                                      assert_expiry)
        }

        /// If a batch has expired, clear its stored_bits on a given shard to
        /// save memory and return true.
        public fun compress_expired_batch_on_shard(shard_address: address,
                                                   primary_address: address,
                                                   batch_index: u64,
        ): bool acquires BitVectorBatchesShard {
            let shard = borrow_global_mut<BitVectorBatchesShard>(shard_address);
            assert(shard.primary == primary_address, 9000);
            
            let batch = Vector::borrow_mut(&mut shard.batch_store, batch_index);
            
            if (time_expired(batch.expiration_time)) {
                Vector::clear(&mut batch.stored_bits);
                return true
            };
            
            false
        }

        /// If a batch has expired, clear its stored_bits across shards to
        /// save memory and return true.
        public fun compress_expired_batch(info: &BitVectorBatchesInfo,
                                          batch_index: u64,
        ): bool acquires BitVectorBatchesShard {
            assert(info.locked, 9000);

            let num_shards = Vector::length(&info.shards);

            let compressed = Option::none<bool>();
            let i = 0;
            while (i < num_shards) {
                let shard_address = *Vector::borrow(&info.shards, i);
                let i_compressed = compress_expired_batch_on_shard(shard_address,
                                                                   info.primary,
                                                                   batch_index);
                // Assert that compression results are consistent across batch.
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
        public fun compress_expired_batches(info: &BitVectorBatchesInfo,
        ) acquires BitVectorBatchesShard {
            let num_batches = Vector::length(&info.batch_total_bits);
            
            let i = 0;
            while (i < num_batches) {
                compress_expired_batch(info, i);
                i = i + 1;
            };
        }

    }
    
}
