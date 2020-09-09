script {
    use 0x1::MoneyOrder;

    /// For now, we receive and forward asset_type_id (as u64), as it's
    /// stored (compactly) in 4 bytes in every money order anyway
    /// according to a fixed convention. Note: explore using TypeTags.
    fun top_up_money_order_asset_holder(issuer: &signer,
                                        asset_type_id: u64,
                                        top_up_amount: u64,
    ) {
        MoneyOrder::top_up_money_order_asset_holder(issuer,
                                                    asset_type_id,
                                                    top_up_amount);
    }
}
