script {
    use 0x1::Debug;
    use 0x1::MoneyOrder;

    /// TODO Some docs
    fun issue_money_order(issuer: &signer,
                          validity_microseconds: u64,
    ) {
        let num_batches = MoneyOrder::issue_money_order(issuer,
                                                        validity_microseconds);
        Debug::print<u64>(&num_batches);
    }
}
