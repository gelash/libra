script {
    use 0x1::MoneyOrder;

    fun deposit_money_order(receiver: &signer,
                            amount: u64,
                            issuer: address,
                            batch_index: u64,
                            order_index: u64,
                            user_public_key: vector<u8>,
                            issuer_signature: vector<u8>,
                            user_signature: vector<u8>,
    ) {
        MoneyOrder::deposit_money_order(receiver,
                                        MoneyOrder::money_order_descriptor(
                                            receiver,
                                            amount,
                                            issuer,
                                            batch_index,
                                            order_index,
                                            user_public_key),
                                        issuer_signature,
                                        user_signature);
    }
}
