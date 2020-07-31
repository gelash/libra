script {
    use 0x1::MoneyOrder;

    /// TODO Some docs
    fun publish_money_order_coin(sender: &signer,
    ) {
        MoneyOrder::publish_money_order_coin(sender);
    }
}
