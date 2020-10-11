address 0x1 {

    module TokenRegistry {
        use 0x1::Errors;
        use 0x1::CoreAddresses;
        use 0x1::Signer;
        use 0x1::Debug;


        resource struct IdCounter {
            count : u64,
        }

        resource struct Registered<CoinType> {
            id : u64,
            metadata : u64, // later change to some metadata struct
        }

        resource struct TokenRegistryWithMintCapability<CoinType> {
            maker_account : address,
        }

        /// A property expected of a `IdCounter` resource didn't hold
        const EID_COUNTER: u64 = 1;

        /// Initialization of the `TokenRegistry` module; initializes
        /// the counter of unique IDs
        public fun initialize(
            config_account: &signer,
        ) {
            assert(
                !exists<IdCounter>(Signer::address_of(config_account)),
                Errors::already_published(EID_COUNTER)
            );
            move_to(config_account, IdCounter {count: 0});
        }

        fun get_fresh_id(): u64 acquires IdCounter{
            let addr = CoreAddresses::TOKEN_REGISTRY_COUNTER_ADDRESS();
            assert(exists<IdCounter>(addr), Errors::not_published(EID_COUNTER));
            let id = borrow_global_mut<IdCounter>(addr);
            id.count = id.count + 1;
            id.count
        }

        public fun register<CoinType>(maker_account: &signer, 
                                    _t: &CoinType,                                
                                    metadata: u64,
        ): TokenRegistryWithMintCapability<CoinType> acquires IdCounter {
            // increments unique counter under global registry address  
            let unique_id = get_fresh_id(); 
            // print for testing, can remove later
            Debug::print(&unique_id);
            move_to<Registered<CoinType>>(
                maker_account,  
                Registered { id: unique_id, metadata }
            ); 
            let address = Signer::address_of(maker_account);
            TokenRegistryWithMintCapability<CoinType>{maker_account: address}
        }


    }
}

          