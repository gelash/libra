
<a name="SCRIPT"></a>

# Script `debug_money_order_coin_balance.move`

### Table of Contents

-  [Function `debug_money_order_coin_balance`](#SCRIPT_debug_money_order_coin_balance)



<a name="SCRIPT_debug_money_order_coin_balance"></a>

## Function `debug_money_order_coin_balance`

TODO Some docs


<pre><code><b>public</b> <b>fun</b> <a href="#SCRIPT_debug_money_order_coin_balance">debug_money_order_coin_balance</a>(sender: &signer, issuer_address: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#SCRIPT_debug_money_order_coin_balance">debug_money_order_coin_balance</a>(sender: &signer,
                                   issuer_address: address,
) {
    <a href="../../modules/doc/Debug.md#0x1_Debug_print">Debug::print</a>&lt;u64&gt;(
        &<a href="../../modules/doc/MoneyOrder.md#0x1_MoneyOrder_money_order_coin_balance">MoneyOrder::money_order_coin_balance</a>(sender, issuer_address));
}
</code></pre>



</details>
