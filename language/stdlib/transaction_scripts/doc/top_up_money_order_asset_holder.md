
<a name="SCRIPT"></a>

# Script `top_up_money_order_asset_holder.move`

### Table of Contents

-  [Function `top_up_money_order_asset_holder`](#SCRIPT_top_up_money_order_asset_holder)



<a name="SCRIPT_top_up_money_order_asset_holder"></a>

## Function `top_up_money_order_asset_holder`

For now, we receive and forward asset_type_id and
asset_specialization_id. These are stored in every money order
Note: explore using TypeTags.


<pre><code><b>public</b> <b>fun</b> <a href="#SCRIPT_top_up_money_order_asset_holder">top_up_money_order_asset_holder</a>(issuer: &signer, asset_type_id: u8, asset_specialization_id: u8, top_up_amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#SCRIPT_top_up_money_order_asset_holder">top_up_money_order_asset_holder</a>(issuer: &signer,
                                    asset_type_id: u8,
                                    asset_specialization_id: u8,
                                    top_up_amount: u64,
) {
    <a href="../../modules/doc/MoneyOrder.md#0x1_MoneyOrder_top_up_money_order_asset_holder">MoneyOrder::top_up_money_order_asset_holder</a>(issuer,
                                                asset_type_id,
                                                asset_specialization_id,
                                                top_up_amount);
}
</code></pre>



</details>
