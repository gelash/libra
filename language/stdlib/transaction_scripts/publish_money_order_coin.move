script {
    use 0x1::MoneyOrder;

    fun publish_money_order_coin(sender: &signer,
    ) {
        MoneyOrder::publish_money_order_coin(sender);
    }
}
