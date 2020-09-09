script {
    use 0x1::MoneyOrder;

    fun publish_money_orders(issuer: &signer,
                             public_key: vector<u8>,
    ) {
        MoneyOrder::publish_money_orders(issuer, public_key);
    }

}
