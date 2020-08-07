//! account: alice
//! account: bob

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        MoneyOrder::initialize_money_orders(
            sender,
            x"27274e2350dcddaa0398abdee291a1ac5d26ac83d9b1ce78200b9defaf2447c1",
            1000000);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        MoneyOrder::issue_money_order_batch(sender, 100, 3600000000, 0);
    }
}
// check: IssuedMoneyOrderEvent
// check: EXECUTED

//! new-transaction
//! sender: bob
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        assert(MoneyOrder::cancel_money_order(
            sender,
            MoneyOrder::money_order_descriptor(
                sender,
                5,
                {{alice}},
                0,
                1,
                x"d7321b63fb76f00b180cf42ba2a28efb9aec217c91cd2a7c3b0d4104b38b63e0"),
            x"6d05aad19caa463862d8698d1bb7c3329a69759f2f3fdda13f3f17e3b31d960187a2ccb010256fb2eb7ea22259581400bc643b88c49f47905f2a37d9ead3840e",
            x"b05f9448482a03b8d94e1e21d48b6ba4aa12554b894320522de856ebccbcb9f559abd3fba819c63125b2fcaadc227d8e8c3836ee57fabe01cb63ce10706e9307"), 8000);
    }
}
// check: ABORTED
// check: 8002

//! new-transaction
//! sender: bob
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        assert(MoneyOrder::cancel_money_order(
            sender,
            MoneyOrder::money_order_descriptor(
                sender,
                5,
                {{alice}},
                0,
                1,
                x"d7321b63fb76f00b180cf42ba2a28efb9aec217c91cd2a7c3b0d4104b38b63e0"),
            x"6d05aad19caa463862d8698d1bb7c3329a69759f2f3fdda13f3f17e3b31d960187a2ccb010256fb2eb7ea22259581400bc643b88c49f47905f2a37d9ead3840e",
            x"a92bb0afe7489f417a0431191594ae8ea484b4952844a2171af5049443fd94d768d70d759552504bf9ee1059984a405534d91997e954de2dc68013596c98e60f"), 8000);
    }
}
// check: CanceledMoneyOrderEvent
// check: EXECUTED

//! new-transaction
//! sender: bob
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        assert(!MoneyOrder::cancel_money_order(
            sender,
            MoneyOrder::money_order_descriptor(
                sender,
                5,
                {{alice}},
                0,
                1,
                x"d7321b63fb76f00b180cf42ba2a28efb9aec217c91cd2a7c3b0d4104b38b63e0"),
            x"6d05aad19caa463862d8698d1bb7c3329a69759f2f3fdda13f3f17e3b31d960187a2ccb010256fb2eb7ea22259581400bc643b88c49f47905f2a37d9ead3840e",
            x"a92bb0afe7489f417a0431191594ae8ea484b4952844a2171af5049443fd94d768d70d759552504bf9ee1059984a405534d91997e954de2dc68013596c98e60f"), 8000);
    }
}
// not: IssuedMoneyOrderEvent
// not: CanceledMoneyOrderEvent
// not: RedeemedMoneyOrderEvent
// check: EXECUTED

//! new-transaction
//! sender: bob
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        MoneyOrder::deposit_money_order(
            sender,
            MoneyOrder::money_order_descriptor(
                sender,
                5,
                {{alice}},
                0,
                1,
                x"d7321b63fb76f00b180cf42ba2a28efb9aec217c91cd2a7c3b0d4104b38b63e0"),
            x"6d05aad19caa463862d8698d1bb7c3329a69759f2f3fdda13f3f17e3b31d960187a2ccb010256fb2eb7ea22259581400bc643b88c49f47905f2a37d9ead3840e",
            x"b05f9448482a03b8d94e1e21d48b6ba4aa12554b894320522de856ebccbcb9f559abd3fba819c63125b2fcaadc227d8e8c3836ee57fabe01cb63ce10706e9307");
    }
}
// check: ABORTED
// check: 8003

//! new-transaction
//! sender: bob
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        MoneyOrder::deposit_money_order(
            sender,
            MoneyOrder::money_order_descriptor(
                sender,
                5,
                {{alice}},
                0,
                10,
                x"a47e5b2bf7cbcc133cea8d7ad17d37ed125a65cfbe8448216ab30e3db0cfab31"),
            x"98d1072c99e9dc7ccd2b6aebaed5aab1fbfb4d95badb13111f192edc3d723ec8f78eb8c1b5d0bf5c5ff6038c7db47631508aa84f7bd76300e96a033f00dc2e0d",
            x"7d7e41659b10f034ba4ebcd9eacaab05da8c82d0676d7a73e370fc022634f38936d650aeae8dcbb8effe06983ed49bdc6b2d1948e23caac475cc97c093570208");
        assert(MoneyOrder::money_order_coin_balance(sender, {{alice}}) == 5, 8000);
        assert(MoneyOrder::money_order_coin_balance(sender, {{bob}}) == 0, 8000);
    }
}
// not: IssuedMoneyOrderEvent
// not: CanceledMoneyOrderEvent
// check: RedeemedMoneyOrderEvent
// check: EXECUTED

//! new-transaction
//! sender: bob
script {
    use 0x1::MoneyOrder;
    fun main(sender: &signer) {
        MoneyOrder::deposit_money_order(
            sender,
            MoneyOrder::money_order_descriptor(
                sender,
                5,
                {{alice}},
                0,
                10,
                x"a47e5b2bf7cbcc133cea8d7ad17d37ed125a65cfbe8448216ab30e3db0cfab31"),
            x"98d1072c99e9dc7ccd2b6aebaed5aab1fbfb4d95badb13111f192edc3d723ec8f78eb8c1b5d0bf5c5ff6038c7db47631508aa84f7bd76300e96a033f00dc2e0d",
            x"7d7e41659b10f034ba4ebcd9eacaab05da8c82d0676d7a73e370fc022634f38936d650aeae8dcbb8effe06983ed49bdc6b2d1948e23caac475cc97c093570208");
        assert(MoneyOrder::money_order_coin_balance(sender, {{alice}}) == 5, 8000);
    }
}
// check: ABORTED
// check: 8003
