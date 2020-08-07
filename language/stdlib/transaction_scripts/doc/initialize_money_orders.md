
<a name="SCRIPT"></a>

# Script `initialize_money_orders.move`

### Table of Contents

-  [Function `initialize_money_orders`](#SCRIPT_initialize_money_orders)



<a name="SCRIPT_initialize_money_orders"></a>

## Function `initialize_money_orders`

TODO Some docs


<pre><code><b>public</b> <b>fun</b> <a href="#SCRIPT_initialize_money_orders">initialize_money_orders</a>(issuer: &signer, public_key: vector&lt;u8&gt;, starting_balance: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#SCRIPT_initialize_money_orders">initialize_money_orders</a>(issuer: &signer,
                            public_key: vector&lt;u8&gt;,
                            starting_balance: u64,
) {
    <a href="../../modules/doc/MoneyOrder.md#0x1_MoneyOrder_initialize_money_orders">MoneyOrder::initialize_money_orders</a>(issuer, public_key, starting_balance);
}
</code></pre>



</details>
