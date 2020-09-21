address 0x1 {

    module TokenIssueCapability {
        use 0x1::Errors;
    	use 0x1::Signer;

        /// Trying to use capability with a wrong issuer address.
        const EWRONG_ISSUER_ADDRESS: u64 = 0;
        /// Trying to use capability with a wrong specialization id of IssuerToken.
        const EWRONG_SPECIALIZATION_ID: u64 = 1;

        /// Allows minting IssuerToken<TokenType>, with issuer address, and TokenType
        /// specialization such that worm_specialization_id<TokenType> on issuer's
        /// account is set to the specialization id (i.e. only allows minting one
        /// specialization of the IssuerToken).
        resource struct TokenIssueCapability {
            issuer_address: address,

            specialization_id: u8,
        }

        /// Need to be extremely careful when creating capabilities, i.e. should
        /// only call it from known interfaces that provide access control, and
        /// not leak the capability besides whatever specific purpose (e.g.
        /// minting MoneyOrderToken when AssetHolder<IssuerToken<MoneyOrderToken>>>
        /// is available).
        public fun capability(issuer: &signer,
                              specialization_id: u8,
        ): TokenIssueCapability {
            TokenIssueCapability {
                issuer_address: Signer::address_of(issuer),
                specialization_id: specialization_id,
            }
        }

        public fun assert_issuer_address(cap: &TokenIssueCapability,
                                         issuer_address: address) {
            assert(cap.issuer_address == issuer_address,
                   Errors::invalid_state(EWRONG_ISSUER_ADDRESS));
        }

        public fun assert_specialization_id(cap: &TokenIssueCapability,
                                            specialization_id: u8) {
            assert(cap.specialization_id == specialization_id,
                   Errors::invalid_state(EWRONG_SPECIALIZATION_ID));
        }
    }
    
}
