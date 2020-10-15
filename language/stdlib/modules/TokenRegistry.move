address 0x1 {

    module TokenRegistry {
        use 0x1::Errors;
        use 0x1::CoreAddresses;
        use 0x1::Signer;
        use 0x1::Debug;


        resource struct IdCounter {
            count: u64,
        }

        resource struct TokenMetadata<CoinType> {
            id: u64,
            transferable: bool,
            // possible other metadata fields can be added here
        }

        resource struct TokenRegistryWithMintCapability<CoinType> {
            maker_account: address,
        }

        resource struct TokenMadeBy<CoinType> { //what should be the fields for this?
            maker_account: address,
        }

        /// A property expected of a `IdCounter` resource didn't hold
        const EID_COUNTER: u64 = 1;
        /// A property expected of a `TokenMetadata` resource didn't hold
        const ETOKEN_REG: u64 = 2;

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
                                    transferable: bool,
        ): TokenRegistryWithMintCapability<CoinType> acquires IdCounter {
            // add test for the line below
            assert(!exists<TokenMetadata<CoinType>>(Signer::address_of(maker_account)), Errors::already_published(ETOKEN_REG));
            // increments unique counter under global registry address  
            let unique_id = get_fresh_id(); 
            // print for testing, can remove later
            Debug::print(&unique_id);
            move_to<TokenMetadata<CoinType>>(
                maker_account,  
                TokenMetadata { id: unique_id, transferable}
            ); 
            let address = Signer::address_of(maker_account);
            TokenRegistryWithMintCapability<CoinType>{maker_account: address}
        }


        /// Asserts that `CoinType` is a registered type at the given address
        // add test
        public fun assert_is_registered_at<CoinType> (registered_at: address){
            assert(exists<TokenMetadata<CoinType>>(registered_at), Errors::not_published(ETOKEN_REG));
        }

        // add test
        public fun is_transferable<CoinType>(registered_at: address): bool acquires TokenMetadata{
            assert_is_registered_at<CoinType>(registered_at);
            let metadata = borrow_global<TokenMetadata<CoinType>>(registered_at);
            metadata.transferable
        }

        // public fun would_not_work<CoinType>(registered_at: address): &TokenMetadata<CoinType> acquires TokenMetadata {
        //     // assert_is_registered_at<CoinType>(registered_at);
        //     let metadata = borrow_global<TokenMetadata<CoinType>>(registered_at);
        //     metadata
        // }


    }
}

          