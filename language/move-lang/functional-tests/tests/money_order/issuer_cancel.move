//! account: alice

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        MoneyOrder::initialize_money_orders(
            sender,
            x"0000000000000000000000000000000000000000000000000000000000000000",
            1000000);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        MoneyOrder::issue_money_order_batch(
            sender,
            100,
            3600000000);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        assert(
            MoneyOrder::issuer_cancel_money_order(
                sender,
                MoneyOrder::money_order_descriptor(
                    sender,
                    5,
                    {{alice}},
                    0,
                    1,
                    x"0000000000000000000000000000000000000000000000000000000000000000")),
            8000);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        assert(
            MoneyOrder::issuer_cancel_money_order(
                sender,
                MoneyOrder::money_order_descriptor(
                    sender,
                    5,
                    {{alice}},
                    0,
                    5,
                    x"0000000000000000000000000000000000000000000000000000000000000000")),
                8000);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        assert(
            !MoneyOrder::issuer_cancel_money_order(
                sender,
                MoneyOrder::money_order_descriptor(
                    sender,
                    5,
                    {{alice}},
                    0,
                    5,
                    x"0000000000000000000000000000000000000000000000000000000000000000")),
                8000);
    }
}
// check: EXECUTED

