script {
    use 0x1::MoneyOrder;

    /// TODO Some docs
    fun issue_money_order_batch(issuer: &signer,
                                batch_size: u64,
                                validity_microseconds: u64,
                                grace_period_microseconds: u64,
    ) {
        MoneyOrder::issue_money_order_batch(issuer,
                                            batch_size,
                                            validity_microseconds,
                                            grace_period_microseconds);
    }
}
