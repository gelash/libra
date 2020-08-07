script {
    use 0x1::MoneyOrder;

    /// TODO Some docs
    fun issue_money_order(issuer: &signer,
                          validity_microseconds: u64,
                          grace_period_microseconds: u64,
    ) {
        MoneyOrder::issue_money_order(issuer,
                                      validity_microseconds,
                                      grace_period_microseconds);
    }
}
