//! account: alice

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        MoneyOrder::initialize_money_orders(
            sender,
            x"d2fbabc7da9925fce1d3d77e75df544bd518d10779a75a53c76c49bfb9f413aa",
            1000000);
    }
}
// not: IssuedMoneyOrderEvent
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        // Immediate expiry.
        MoneyOrder::issue_money_order_batch(sender, 100, 0, 0);
        // Second batch with no expiry (time is always 0 in unit tests).
        MoneyOrder::issue_money_order_batch(sender, 10, 3600000000, 0);
    }
}
// not: CanceledMoneyOrderEvent
// check: IssuedMoneyOrderEvent
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        // Immediate expiry.
        MoneyOrder::issue_money_order_batch(sender, 20, 0, 0);
    }
}
// not: CanceledMoneyOrderEvent
// check: IssuedMoneyOrderEvent
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        // Note: in unit testing setting, time is always 0, so batches
        // 0 and 2 that were issued with duration 0 are always expired,
        // and batch 1 is never expired.
        assert(!MoneyOrder::issuer_cancel_money_order(sender, 0, 2), 8000);
        assert(!MoneyOrder::issuer_cancel_money_order(sender, 2, 2), 8000);
        // Not expired.
        assert(MoneyOrder::issuer_cancel_money_order(sender, 1, 2), 8000);
    }
}
// not: IssuedMoneyOrderEvent
// check: CanceledMoneyOrderEvent
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        // Clean up order statuses for batch 0.
        assert(MoneyOrder::compress_expired_batch(sender, 0), 8000);
        
        // Can't compress (clear up order_statuses), since batch 1
        // hasn't expired.
        assert(!MoneyOrder::compress_expired_batch(sender, 1), 8000);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        // Already cleaned up.
        assert(!MoneyOrder::compress_expired_batch(sender, 0), 8000);

        MoneyOrder::compress_expired_batches(sender);
        // Batch 2 is now compressed by the above call.
        assert(!MoneyOrder::compress_expired_batch(sender, 2), 8000);
        
        // Still can't compress batch 1, as it's not expired.
        assert(!MoneyOrder::compress_expired_batch(sender, 2), 8000);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    // Check no aborts even when expired batches are compressed.
    fun main(sender: &signer) {
        assert(!MoneyOrder::issuer_cancel_money_order(sender, 0, 3), 8000);
        assert(!MoneyOrder::issuer_cancel_money_order(sender, 2, 3), 8000);
        // Not expired.
        assert(MoneyOrder::issuer_cancel_money_order(sender, 1, 3), 8000);
    }
}
// check: CanceledMoneyOrderEvent
// check: EXECUTED
