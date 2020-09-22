address 0x1 {

    module IssuerToken {
        use 0x1::CoreAddresses;
        use 0x1::Errors;
        use 0x1::Event::{Self, EventHandle};
        use 0x1::Signer;
        use 0x1::TokenIssueCapability::{Self, TokenIssueCapability};
        use 0x1::Vector;

        /// RedeemedIssuerTokenEvent, when emitted, serves as a unique certificate
        /// that the sender burnt a specified amount of the specified issuer token
        /// type. Once an amount is burnt, it's subtracted from the available amount.
        struct RedeemedIssuerTokenEvent {
            /// Information identifying the issuer token. 'specialization_id' is
            /// a byte that specifies the what <TokenType> parameter was used
            /// according to a fixed convention (currently, we use the declaration
            /// order in this module, e.g. DefaultToken is 0, MoneyOrderToken is 1).
            specialization_id: u8,
            issuer_address: address,
            band_id: u64,

            /// Amount of the IssuerTokens that were redeemed.
            redeemed_amount: u64,
            
            // Note: could also record left_amount. TODO: consider adding.
        }

        /// The main IssuerToken wrapper resource. Shouldn't be stored on accounts
        /// directly, but rather be wrapped inside IssuerTokenContainer for tokens
        /// issued by other accounts, and BalanceHolder for distributing tokens
        /// issued by the holding account. Once distributed, issuer tokens should
        /// never go back to issuer, they can only be redeemed (i.e. burnt & exhanged
        /// for the Redeem event that certifies the burn/redemption).
        /// Note: DefaultToken specialization uses a single band.
        resource struct IssuerToken<TokenType> {
            /// The issuer is the only entity that can authorize issuing these
            /// tokens (by directly calling, or manual cryptographic guarantees).
            issuer_address: address,

            /// issuer tokens of the same type but different bands can be
            /// treated as different tokens, hence, allowing issuers to issue
            /// differently "typed" tokens at runtime, when needed.
            band_id: u64,

            /// the amount of stored issuer tokens (of the specified type and band).
            amount: u64,
        }

        /// Container for holding redeemed issuer tokens on accounts (i.e.
        /// on accounts other than the issuer).
        resource struct IssuerTokenContainer<IssuerTokenType> {
            // TODO: A Map keyed by address and generation would be a better
            // data-structure, when it becomes available.
            issuer_tokens: vector<IssuerTokenType>,

            /// Event stream for redeeming IssuerTokens (emits these events).
            redemption_events: EventHandle<RedeemedIssuerTokenEvent>,
        }


        /// Trying to deposit funds that would have surpassed the account's limits
        const EDEPOSIT_EXCEEDS_LIMITS: u64 = 0;
        /// Issuer depositing own coins on its account (in IssuerTokenContainer structure).
        const ESELF_DEPOSIT: u64 = 1;
        /// Trying to merge different issuer tokens.
        const EILLEGAL_MERGE: u64 = 2;
        /// A redemption was attempted with non-positive amount
        const EREDEEM_NON_POSITIVE: u64 = 3;
        /// A redemption of IssuerToken<TokenType>> was attempted, but the matching
        /// IssuerTokenContainer didn't exist on the account.
        const EMISSING_CONTAINER: u64 = 4;
        /// Could not find issuer token based on address
        const EISSUER_TOKEN_NOT_FOUND: u64 = 5;
        /// Trying to redeem amount surpassing the account's limits
        const EREDEEM_EXCEEDS_LIMITS: u64 = 6;
        /// Registering a negative specialization id for a TokenType.
        const ESPECIALIZATION_ID_NEGATIVE: u64 = 7;
        /// Registering a non-unique specialization id for a TokenType.
        const ESPECIALIZATION_ID_NON_UNIQUE: u64 = 8;
        /// Registering worm specialization id for TokenType with conflicting IDs.
        const ESPECIALIZATION_ID_CONFLICT: u64 = 9;
        /// Using TokenType that doesn't have a registered specialization id.
        const ESPECIALIZATION_ID_NOT_FOUND: u64 = 10; 

        /// Write-once read-many resource that when published on issuer's account,
        /// uniquely identifies a given TokenType for the issuer. Redemption events
        /// identify TokenType using the ID based on this structure, which is why
        /// it's required that (1) the worm_specialization_id<TokenType> exists
        /// on issuer's account; (2) all mapped ID's are unique; and (3) once
        /// published, the ID's are immutable.
        resource struct WormSpecializationId<TokenType> {
            specialization_id: u8,
        }

        /// Used to ensure uniqueness of WormSpecializationId's.
        resource struct IssuerTokenSpecializationIds {
            // TODO: change to a set data-structure.
            all_ids: vector<u8>,
        }

        /// Find the specialization Id for a given TokenType specialization for
        /// a given issuer address. Returns (false, 0) if IssuerToken<TokenType>
        /// not yet in use by the issuer (account w. issuer_address).
        public fun worm_specialization_id<TokenType>(issuer_address: address,
        ): (bool, u8) acquires WormSpecializationId {
            if (!exists<WormSpecializationId<TokenType>>(issuer_address)) {
                return (false, 0)
            };
            
            let worm_id =
                borrow_global<WormSpecializationId<TokenType>>(issuer_address);
            (true, worm_id.specialization_id)
        }

        // Ensure specialization id hasn't already been set to something else.
        fun assert_unique_specialization_id<TokenType>(account_address: address,
                                                       specialization_id: u8,
        ) acquires WormSpecializationId {
            let (found, worm_id) = worm_specialization_id<TokenType>(account_address);
            assert(!found || worm_id == specialization_id,
                   Errors::invalid_state(ESPECIALIZATION_ID_CONFLICT));
        }
        
        /// Before using IssuerToken<TokenType>, every issuer account must register
        /// the TokenType by calling register_token_specialization<TokenType> providing
        /// a unique specialization ID (which cannot be reset later). This is used to
        /// identify the type of issuer token in events, etc.
        ///
        /// For TokenTypes that are registered with a unique ID on the Libra root
        /// account during genesis, the same ID must be used (e.g. DefaultToken must
        /// have specialization id 0 when being registered by any account).
        public fun register_token_specialization<TokenType>(issuer: &signer,
                                                            specialization_id: u8,
        ) acquires IssuerTokenSpecializationIds, WormSpecializationId {
            assert(specialization_id >= 0,
                   Errors::invalid_argument(ESPECIALIZATION_ID_NEGATIVE));
            
            let issuer_address = Signer::address_of(issuer);
            if (!exists<IssuerTokenSpecializationIds>(issuer_address)) {
                move_to(issuer, IssuerTokenSpecializationIds {
                    all_ids: Vector::empty(),
                });
            };

            // Ensure specialization id not previously set to something else
            // on issuer's or Libra_root's account.
            assert_unique_specialization_id<TokenType>(issuer_address,
                                                       specialization_id);
            assert_unique_specialization_id<TokenType>(CoreAddresses::LIBRA_ROOT_ADDRESS(),
                                                       specialization_id);

            if (!exists<WormSpecializationId<TokenType>>(issuer_address)) {
                let ids = borrow_global_mut<IssuerTokenSpecializationIds>(issuer_address);
                // Ensure specialization_id is unique.
                assert(!Vector::contains(&ids.all_ids, &specialization_id),
                       Errors::invalid_argument(ESPECIALIZATION_ID_NON_UNIQUE));

                // Set specialization id and record in all ids.
                move_to(issuer, WormSpecializationId<TokenType> {
                    specialization_id: specialization_id, 
                });
                Vector::push_back(&mut ids.all_ids, specialization_id);
            }
        }
        
        /// Publishes the IssuerTokenContainer struct on sender's account, allowing it
        /// to hold tokens of IssuerTokenType issued by other accounts.
        public fun publish_issuer_token_container<TokenType>(sender: &signer) {
            // TODO: when available, use aliasing for IssuerToken<TokenType>
            let sender_address = Signer::address_of(sender);
            
            if (!exists<IssuerTokenContainer<IssuerToken<TokenType>>>(sender_address)) {
                move_to(sender, IssuerTokenContainer<IssuerToken<TokenType>> {
                    issuer_tokens: Vector::empty(),
                    redemption_events: Event::new_event_handle<RedeemedIssuerTokenEvent>(
                        sender)
                });
            };
        }
        
        // Find the issuer token based on address.
        fun find_issuer_token<TokenType>(
            issuer_token_vector: &vector<IssuerToken<TokenType>>,
            issuer_address: address,
            band_id: u64,
        ): (bool, u64) {
            let i = 0;
            while (i < Vector::length(issuer_token_vector)) {
                let token = Vector::borrow(issuer_token_vector, i);
                if (token.issuer_address == issuer_address &&
                    token.band_id == band_id) {
                    return (true, i)
                };
                
                i = i + 1;
            };
            (false, 0)
        }

        /// Sender can mint arbitrary amounts of its own IssuerToken
        /// (with its own address).
        public fun mint_issuer_token<TokenType>(issuer: &signer,
                                                band_id: u64,
                                                amount: u64,
        ): IssuerToken<TokenType> {
            let issuer_address = Signer::address_of(issuer);

            IssuerToken<TokenType> {
                issuer_address: issuer_address,
                band_id: band_id,
                amount: amount
            }
        }

        /// Sender can mint arbitrary amounts of its own IssuerToken
        /// (with its own address).
        public fun mint_issuer_token_with_capability<TokenType>(
            capability: &TokenIssueCapability,
            issuer_address: address,
            band_id: u64,
            amount: u64,
        ): IssuerToken<TokenType> acquires WormSpecializationId {
            // Make sure capability matches the issuer address and the
            // specialization id corresponding to the TokenType.
            TokenIssueCapability::assert_issuer_address(capability,
                                                        issuer_address);
            let (found, worm_id) =
                worm_specialization_id<TokenType>(issuer_address);
            assert(found, Errors::invalid_state(ESPECIALIZATION_ID_NOT_FOUND));
            TokenIssueCapability::assert_specialization_id(capability,
                                                           worm_id);

            IssuerToken<TokenType> {
                issuer_address: issuer_address,
                band_id: band_id,
                amount: amount
            }
        }

        /// Merge two IssuerTokens, i.e. combine the amounts of two tokens
        /// into the first one (the second token gets destroyed).
        public fun merge_issuer_token<TokenType>(
            issuer_token_a: &mut IssuerToken<TokenType>,
            issuer_token_b: IssuerToken<TokenType>,
        ) {
            let IssuerToken<TokenType> { issuer_address,
                                         band_id,
                                         amount } = issuer_token_b;
            
            assert(issuer_token_a.issuer_address == issuer_address,
                   Errors::invalid_argument(EILLEGAL_MERGE));
            assert(issuer_token_a.band_id == band_id,
                   Errors::invalid_argument(EILLEGAL_MERGE));

            let token_amount = &mut issuer_token_a.amount;
            *token_amount = *token_amount + amount;
        }

        /// Extract a token of specified amount out of a given token (whose amount
        /// is decreased accordingly).
        public fun split_issuer_token<TokenType>(
            issuer_token: &mut IssuerToken<TokenType>,
            amount: u64,
        ): IssuerToken<TokenType> {
            assert(issuer_token.amount >= amount,
                   Errors::limit_exceeded(EDEPOSIT_EXCEEDS_LIMITS));            
            let token_amount = &mut issuer_token.amount;
            *token_amount = *token_amount - amount;

            IssuerToken<TokenType> {
                issuer_address: issuer_token.issuer_address,
                band_id: issuer_token.band_id,
                amount: amount,
            }
        }

        /// Returns the `amount` of the passed in `issuer_token`.
        public fun value<TokenType>(issuer_token: &IssuerToken<TokenType>): u64 {
            issuer_token.amount
        }

        /// Returns the balance of a particular IssuerToken type (determined by the
        /// TokenType specialization, issuer_address and band_id) on senders account
        /// (in its IssuerTokenContainer to be precise). If the container doesn't exist
        /// or contain the type of IssuerToken, value 0 is returned.
        /// Note: One of the primary uses of this function is for the unit tests.
        public fun issuer_token_balance<TokenType>(sender: &signer,
                                                   issuer_address: address,
                                                   band_id: u64,
        ): u64 acquires IssuerTokenContainer {
            let sender_address = Signer::address_of(sender);
            if (!exists<IssuerTokenContainer<IssuerToken<TokenType>>>(sender_address)) {
                return 0
            };
            let sender_tokens =
                borrow_global<IssuerTokenContainer<IssuerToken<TokenType>>>(sender_address);
            
            let (found, target_index) =
                find_issuer_token<TokenType>(&sender_tokens.issuer_tokens,
                                             issuer_address,
                                             band_id);
            if (!found) return 0;

            let issuer_token = Vector::borrow(&sender_tokens.issuer_tokens, target_index);
            issuer_token.amount
        }
        
        /// Deposits the issuer token in the IssuerTokenContainer structure on receiver's account.
        /// It's asserted that receiver != issuer, and IssuerTokenContainer<TokenType> is created
        /// if not already published on the receiver's account.
        public fun deposit_issuer_token<TokenType>(receiver: &signer,
                                                   issuer_token: IssuerToken<TokenType>,
        ) acquires IssuerTokenContainer {
            let receiver_address = Signer::address_of(receiver);
            assert(issuer_token.issuer_address != receiver_address, Errors::invalid_argument(ESELF_DEPOSIT));

            // If the container doesn't exist, will publish it, allowing to hold IssuerTokens.
            publish_issuer_token_container<TokenType>(receiver);
            let receiver_tokens =
                borrow_global_mut<IssuerTokenContainer<IssuerToken<TokenType>>>(receiver_address);

            let (found, target_index) =
                find_issuer_token<TokenType>(&receiver_tokens.issuer_tokens,
                                             issuer_token.issuer_address,
                                             issuer_token.band_id);
            if (!found) {
                // If a issuer token with given type and band_id is not stored,
                // store one with 0 amount.
                target_index = Vector::length(&receiver_tokens.issuer_tokens);
                Vector::push_back(&mut receiver_tokens.issuer_tokens,
                                  IssuerToken<TokenType> {
                                      issuer_address: issuer_token.issuer_address,
                                      band_id: issuer_token.band_id,
                                      amount: 0
                                  });
            };
            
            // Actually increment the issuer token amount.
            merge_issuer_token(Vector::borrow_mut(&mut receiver_tokens.issuer_tokens,
                                                  target_index),
                               issuer_token);
        }

        // Destroys the given token and emits the RedeemedIssuerToken event on the handle.
        // Note: We bottleneck redemption functionality to the IssuerTokenContainer structure
        // (which contains the event handle): i.e. in order to redeem a given issuer token,
        // the sender should first deposit it to the container, then redeem/burn it. This is a
        // minor inconvenience on the caller side, but makes the IssuerToken module
        // implementation and APIs cleaner.
        fun redeem_issuer_token<TokenType>(to_redeem_token: IssuerToken<TokenType>,
                                           event_handle: &mut EventHandle<RedeemedIssuerTokenEvent>,
        ) acquires WormSpecializationId {
             // Destroy the actual token.
            let IssuerToken<TokenType> {issuer_address,
                                        band_id,
                                        amount,} = to_redeem_token;
            // Can't redeem non-positive amounts. Negative amounts don't make sense, and while
            // it's okay to destroy IssuerToken with 0 amount, it doesn't need redemption events.
            assert(amount > 0, Errors::invalid_argument(EREDEEM_NON_POSITIVE));

            let (found, worm_id) = worm_specialization_id<TokenType>(issuer_address);
            assert(found, Errors::invalid_state(ESPECIALIZATION_ID_NOT_FOUND));
            
            // Emit the corresponding redemption event.
            Event::emit_event(
                event_handle,
                RedeemedIssuerTokenEvent {
                    specialization_id: worm_id,
                    issuer_address: issuer_address,
                    band_id: band_id,
                    redeemed_amount: amount,
                }
            );
        }

        /// Redeems the to_redeem_amount of IssuerToken (with a given issuer address & band_id)
        /// from the IssuerTokenContainer on sender's account. Redemption is accomplished by
        /// burning the specified amount (subtracting from available amount) and logging a
        /// redemption event that serves as a certificate. Emits error if insufficient balance.
        public fun redeem<TokenType>(sender: &signer,
                                     issuer_address: address,
                                     band_id: u64,
                                     to_redeem_amount: u64,
        ) acquires IssuerTokenContainer, WormSpecializationId {
            assert(to_redeem_amount > 0, Errors::invalid_argument(EREDEEM_NON_POSITIVE));
            
            let sender_address = Signer::address_of(sender);
            assert(exists<IssuerTokenContainer<IssuerToken<TokenType>>>(sender_address),
                   Errors::invalid_state(EMISSING_CONTAINER));
            let sender_tokens =
                borrow_global_mut<IssuerTokenContainer<IssuerToken<TokenType>>>(sender_address);

            let (found, target_index) =
                find_issuer_token<TokenType>(&sender_tokens.issuer_tokens,
                                             issuer_address,
                                             band_id);
            assert(found, Errors::invalid_state(EISSUER_TOKEN_NOT_FOUND));
            let issuer_token = Vector::borrow_mut(&mut sender_tokens.issuer_tokens, target_index);
            assert(issuer_token.amount >= to_redeem_amount,
                   Errors::limit_exceeded(EREDEEM_EXCEEDS_LIMITS));

            // Split the issuer_token, redeem the specified amount and emit corresponding event.
            redeem_issuer_token<TokenType>(split_issuer_token<TokenType>(issuer_token,
                                                                         to_redeem_amount),
                                           &mut sender_tokens.redemption_events);

            // Clear the IssuerToken from Container if the amount is 0.
            // Note: we could make this a private utility function if useful elsewhere.
            if (issuer_token.amount == 0){
                let IssuerToken<TokenType> {issuer_address: _,
                                            band_id: _,
                                            amount: _ } =
                    Vector::swap_remove(&mut sender_tokens.issuer_tokens, target_index);
            };
        }

        /// Redeems all available amount of IssuerToken (with a given issuer address & band_id)
        /// from the IssuerTokenContainer on sender's account. Available balance has to be > 0.
        fun redeem_all<TokenType>(sender: &signer,
                                  issuer_address: address,
                                  band_id: u64,
        ) acquires IssuerTokenContainer, WormSpecializationId {
            let total_amount = issuer_token_balance<TokenType>(sender, issuer_address, band_id);
            
            // redeem<TokenType> will check that total_amount > 0.
            redeem<TokenType>(sender,
                              issuer_address,
                              band_id,
                              total_amount);
        }
    }

}
