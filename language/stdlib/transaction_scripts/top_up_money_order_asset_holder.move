script {
    use 0x1::MoneyOrder;

    /// For now, we receive and forward asset_type_id and
    /// asset_specialization_id. These are stored in every money order
    /// Note: explore using TypeTags.
    fun top_up_money_order_asset_holder(issuer: &signer,
                                        asset_type_id: u8,
                                        asset_specialization_id: u8,
                                        top_up_amount: u64,
    ) {
        MoneyOrder::top_up_money_order_asset_holder(issuer,
                                                    asset_type_id,
                                                    asset_specialization_id,
                                                    top_up_amount);
    }
}
