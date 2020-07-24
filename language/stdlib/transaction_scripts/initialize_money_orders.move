script {
    use 0x1::MoneyOrder;

    fun initialize_money_orders(issuer: &signer,
                                public_key: vector<u8>,
                                starting_balance: u64,
    ) {
        MoneyOrder::initialize_money_orders(issuer, public_key, starting_balance);
    }
}
