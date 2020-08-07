
<a name="SCRIPT"></a>

# Script `issuer_cancel_money_order.move`

### Table of Contents

-  [Function `issuer_cancel_money_order`](#SCRIPT_issuer_cancel_money_order)



<a name="SCRIPT_issuer_cancel_money_order"></a>

## Function `issuer_cancel_money_order`

TODO Some docs


<pre><code><b>public</b> <b>fun</b> <a href="#SCRIPT_issuer_cancel_money_order">issuer_cancel_money_order</a>(issuer: &signer, batch_index: u64, order_index: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#SCRIPT_issuer_cancel_money_order">issuer_cancel_money_order</a>(issuer: &signer,
                              batch_index: u64,
                              order_index: u64,
) {
    <a href="../../modules/doc/MoneyOrder.md#0x1_MoneyOrder_issuer_cancel_money_order">MoneyOrder::issuer_cancel_money_order</a>(issuer, batch_index, order_index);
}
</code></pre>



</details>
