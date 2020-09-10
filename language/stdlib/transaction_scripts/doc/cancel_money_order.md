
<a name="SCRIPT"></a>

# Script `cancel_money_order.move`

### Table of Contents

-  [Function `cancel_money_order`](#SCRIPT_cancel_money_order)



<a name="SCRIPT_cancel_money_order"></a>

## Function `cancel_money_order`

TODO: docs.


<pre><code><b>public</b> <b>fun</b> <a href="#SCRIPT_cancel_money_order">cancel_money_order</a>(receiver: &signer, amount: u64, asset_type_id: u8, asset_specialization_id: u8, issuer: address, batch_index: u64, order_index: u64, user_public_key: vector&lt;u8&gt;, issuer_signature: vector&lt;u8&gt;, user_signature: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#SCRIPT_cancel_money_order">cancel_money_order</a>(receiver: &signer,
                       amount: u64,
                       asset_type_id: u8,
                       asset_specialization_id: u8,
                       issuer: address,
                       batch_index: u64,
                       order_index: u64,
                       user_public_key: vector&lt;u8&gt;,
                       issuer_signature: vector&lt;u8&gt;,
                       user_signature: vector&lt;u8&gt;,
) {
    <a href="../../modules/doc/MoneyOrder.md#0x1_MoneyOrder_cancel_money_order">MoneyOrder::cancel_money_order</a>(receiver,
                                   <a href="../../modules/doc/MoneyOrder.md#0x1_MoneyOrder_money_order_descriptor">MoneyOrder::money_order_descriptor</a>(
                                       receiver,
                                       amount,
                                       asset_type_id,
                                       asset_specialization_id,
                                       issuer,
                                       batch_index,
                                       order_index,
                                       user_public_key),
                                   issuer_signature,
                                   user_signature);
}
</code></pre>



</details>
