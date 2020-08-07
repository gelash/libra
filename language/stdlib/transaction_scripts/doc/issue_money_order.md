
<a name="SCRIPT"></a>

# Script `issue_money_order.move`

### Table of Contents

-  [Function `issue_money_order`](#SCRIPT_issue_money_order)



<a name="SCRIPT_issue_money_order"></a>

## Function `issue_money_order`

TODO Some docs


<pre><code><b>public</b> <b>fun</b> <a href="#SCRIPT_issue_money_order">issue_money_order</a>(issuer: &signer, validity_microseconds: u64, grace_period_microseconds: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#SCRIPT_issue_money_order">issue_money_order</a>(issuer: &signer,
                      validity_microseconds: u64,
                      grace_period_microseconds: u64,
) {
    <a href="../../modules/doc/MoneyOrder.md#0x1_MoneyOrder_issue_money_order">MoneyOrder::issue_money_order</a>(issuer,
                                  validity_microseconds,
                                  grace_period_microseconds);
}
</code></pre>



</details>
