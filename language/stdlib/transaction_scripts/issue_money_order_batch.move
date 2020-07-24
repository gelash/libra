script {
    use 0x1::Debug;
    use 0x1::MoneyOrder;

    fun issue_money_order_batch(issuer: &signer,
                                batch_size: u64,
                                validity_microseconds: u64,
    ) {
        let num_batches = MoneyOrder::issue_money_order_batch(issuer,
                                                              batch_size,
                                                              validity_microseconds);
        Debug::print<u64>(&num_batches);
    }
}
