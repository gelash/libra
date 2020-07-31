script {
    use 0x1::MoneyOrder;

    /// TODO Some docs
    fun issuer_cancel_money_order(issuer: &signer,
                                  batch_index: u64,
                                  order_index: u64,
    ) {
        MoneyOrder::issuer_cancel_money_order(issuer, batch_index, order_index);
    }
}
