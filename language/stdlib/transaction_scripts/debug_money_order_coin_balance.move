script {
    use 0x1::Debug;
    use 0x1::MoneyOrder;

    /// TODO Some docs
    fun debug_money_order_coin_balance(sender: &signer,
                                       issuer_address: address,
    ) {
        Debug::print<u64>(
            &MoneyOrder::money_order_coin_balance(sender, issuer_address));
    }
}
