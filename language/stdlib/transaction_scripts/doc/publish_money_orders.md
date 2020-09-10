
<a name="SCRIPT"></a>

# Script `publish_money_orders.move`

### Table of Contents

-  [Function `publish_money_orders`](#SCRIPT_publish_money_orders)



<a name="SCRIPT_publish_money_orders"></a>

## Function `publish_money_orders`



<pre><code><b>public</b> <b>fun</b> <a href="#SCRIPT_publish_money_orders">publish_money_orders</a>(issuer: &signer, public_key: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#SCRIPT_publish_money_orders">publish_money_orders</a>(issuer: &signer,
                         public_key: vector&lt;u8&gt;,
) {
    <a href="../../modules/doc/MoneyOrder.md#0x1_MoneyOrder_publish_money_orders">MoneyOrder::publish_money_orders</a>(issuer, public_key);
}
</code></pre>



</details>
