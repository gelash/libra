
<a name="0x1_AssetHolder"></a>

# Module `0x1::AssetHolder`

### Table of Contents

-  [Resource `AssetHolder`](#0x1_AssetHolder_AssetHolder)
-  [Function `create_default_issuer_token_holder`](#0x1_AssetHolder_create_default_issuer_token_holder)
-  [Function `create_libra_holder`](#0x1_AssetHolder_create_libra_holder)
-  [Function `initialize`](#0x1_AssetHolder_initialize)
-  [Function `top_up_default_issuer_token_holder`](#0x1_AssetHolder_top_up_default_issuer_token_holder)
-  [Function `top_up_libra_holder`](#0x1_AssetHolder_top_up_libra_holder)
-  [Function `deposit_default_issuer_token`](#0x1_AssetHolder_deposit_default_issuer_token)
-  [Function `deposit_libra`](#0x1_AssetHolder_deposit_libra)



<a name="0x1_AssetHolder_AssetHolder"></a>

## Resource `AssetHolder`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_AssetHolder">AssetHolder</a>&lt;AssetType&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>owner: address</code>
</dt>
<dd>

</dd>
<dt>

<code>asset: AssetType</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_AssetHolder_create_default_issuer_token_holder"></a>

## Function `create_default_issuer_token_holder`

Returns an AssetHolder holding IssuerToken<DefaultToken> with 0
amount. Note: Band for DefaultToken is always 0.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_create_default_issuer_token_holder">create_default_issuer_token_holder</a>(issuer: &signer): <a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_DefaultToken">IssuerToken::DefaultToken</a>&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_create_default_issuer_token_holder">create_default_issuer_token_holder</a>(issuer: &signer
): <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;DefaultToken&gt;&gt; {
    <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;DefaultToken&gt;&gt; {
        owner: <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer),
        asset: <a href="IssuerToken.md#0x1_IssuerToken_mint_issuer_token">IssuerToken::mint_issuer_token</a>&lt;DefaultToken&gt;(
            issuer,
            0,
            0)
    }
}
</code></pre>



</details>

<a name="0x1_AssetHolder_create_libra_holder"></a>

## Function `create_libra_holder`

Returns an AssetHolder holding Libra<CoinType> with 0 value.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_create_libra_holder">create_libra_holder</a>&lt;CoinType&gt;(issuer: &signer): <a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="Libra.md#0x1_Libra_Libra">Libra::Libra</a>&lt;CoinType&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_create_libra_holder">create_libra_holder</a>&lt;CoinType&gt;(issuer: &signer
): <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="Libra.md#0x1_Libra">Libra</a>&lt;CoinType&gt;&gt; {
    <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="Libra.md#0x1_Libra">Libra</a>&lt;CoinType&gt;&gt; {
        owner: <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer),
        asset: <a href="Libra.md#0x1_Libra_zero">Libra::zero</a>&lt;CoinType&gt;(),
    }
}
</code></pre>



</details>

<a name="0x1_AssetHolder_initialize"></a>

## Function `initialize`

Can only be called during genesis with libra root account.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_initialize">initialize</a>(lr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_initialize">initialize</a>(lr_account: &signer) {
    <a href="LibraTimestamp.md#0x1_LibraTimestamp_assert_genesis">LibraTimestamp::assert_genesis</a>();

    // Publish for relevant <a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a> types.
    move_to(lr_account,
            <a href="#0x1_AssetHolder_create_default_issuer_token_holder">create_default_issuer_token_holder</a>(lr_account));
    move_to(lr_account,
            <a href="#0x1_AssetHolder_create_libra_holder">create_libra_holder</a>&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;(lr_account));
    move_to(lr_account,
            <a href="#0x1_AssetHolder_create_libra_holder">create_libra_holder</a>&lt;<a href="Coin2.md#0x1_Coin2">Coin2</a>&gt;(lr_account));
    move_to(lr_account,
            <a href="#0x1_AssetHolder_create_libra_holder">create_libra_holder</a>&lt;<a href="LBR.md#0x1_LBR">LBR</a>&gt;(lr_account));
}
</code></pre>



</details>

<a name="0x1_AssetHolder_top_up_default_issuer_token_holder"></a>

## Function `top_up_default_issuer_token_holder`

Adds IssuerToken<DefaultToken> to the AssetHolder on issuer's
account. Note: For now, band for DefaultToken is always 0.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_top_up_default_issuer_token_holder">top_up_default_issuer_token_holder</a>(issuer: &signer, holder: &<b>mut</b> <a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_DefaultToken">IssuerToken::DefaultToken</a>&gt;&gt;, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_top_up_default_issuer_token_holder">top_up_default_issuer_token_holder</a>(
    issuer: &signer,
    holder: &<b>mut</b> <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;DefaultToken&gt;&gt;,
    amount: u64,
) {
    // Issuer should be the holder's owner.
    <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer) == holder.owner, 9000);
    // Top up amount should be positive.
    <b>assert</b>(amount &gt; 0, 9000);

    <a href="IssuerToken.md#0x1_IssuerToken_merge_issuer_token">IssuerToken::merge_issuer_token</a>&lt;DefaultToken&gt;(
        &<b>mut</b> holder.asset,
        <a href="IssuerToken.md#0x1_IssuerToken_mint_issuer_token">IssuerToken::mint_issuer_token</a>&lt;DefaultToken&gt;(issuer,
                                                     0,
                                                     amount));
}
</code></pre>



</details>

<a name="0x1_AssetHolder_top_up_libra_holder"></a>

## Function `top_up_libra_holder`

Adds Libra<CoinType> withdrawn from issuer's balance to the
AssetHolder on issuer's account.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_top_up_libra_holder">top_up_libra_holder</a>&lt;CoinType&gt;(issuer: &signer, holder: &<b>mut</b> <a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="Libra.md#0x1_Libra_Libra">Libra::Libra</a>&lt;CoinType&gt;&gt;, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_top_up_libra_holder">top_up_libra_holder</a>&lt;CoinType&gt;(
    issuer: &signer,
    holder: &<b>mut</b> <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="Libra.md#0x1_Libra">Libra</a>&lt;CoinType&gt;&gt;,
    amount: u64,
) {
    // Issuer should be the holder's owner.
    <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer) == holder.owner, 9000);
    // Top up amount should be positive.
    <b>assert</b>(amount &gt; 0, 9000);

    <a href="Libra.md#0x1_Libra_deposit">Libra::deposit</a>&lt;CoinType&gt;(
        &<b>mut</b> holder.asset,
        <a href="LibraAccount.md#0x1_LibraAccount_withdraw_libra">LibraAccount::withdraw_libra</a>(issuer, amount));
}
</code></pre>



</details>

<a name="0x1_AssetHolder_deposit_default_issuer_token"></a>

## Function `deposit_default_issuer_token`

Takes IssuerToken<DefaultToken> from the AssetHolder and deposits
on receivers account (stored in the IssuerTokenContainer struct).
Note: For now, band for DefaultToken is always 0.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_deposit_default_issuer_token">deposit_default_issuer_token</a>(receiver: &signer, holder: &<b>mut</b> <a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_DefaultToken">IssuerToken::DefaultToken</a>&gt;&gt;, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_deposit_default_issuer_token">deposit_default_issuer_token</a>(
    receiver: &signer,
    holder: &<b>mut</b> <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;DefaultToken&gt;&gt;,
    amount: u64,
) {
    // Deposit amount should be positive.
    <b>assert</b>(amount &gt; 0, 9000);

    <b>let</b> issuer_tokens =
        <a href="IssuerToken.md#0x1_IssuerToken_split_issuer_token">IssuerToken::split_issuer_token</a>&lt;DefaultToken&gt;(&<b>mut</b> holder.asset,
                                                      amount);

    // This call also asserts that receiver != issuer
    <a href="IssuerToken.md#0x1_IssuerToken_deposit_issuer_token">IssuerToken::deposit_issuer_token</a>&lt;DefaultToken&gt;(receiver,
                                                    issuer_tokens);
}
</code></pre>



</details>

<a name="0x1_AssetHolder_deposit_libra"></a>

## Function `deposit_libra`

Takes Libra<CoinType> from the AssetHolder and deposits on
receivers account balance.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_deposit_libra">deposit_libra</a>&lt;CoinType&gt;(receiver: &signer, holder: &<b>mut</b> <a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="Libra.md#0x1_Libra_Libra">Libra::Libra</a>&lt;CoinType&gt;&gt;, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_deposit_libra">deposit_libra</a>&lt;CoinType&gt;(
    receiver: &signer,
    holder: &<b>mut</b> <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="Libra.md#0x1_Libra">Libra</a>&lt;CoinType&gt;&gt;,
    amount: u64,
) {
    // Deposit amount should be positive.
    <b>assert</b>(amount &gt; 0, 9000);

    <b>let</b> taken_libra = <a href="Libra.md#0x1_Libra_withdraw">Libra::withdraw</a>&lt;CoinType&gt;(&<b>mut</b> holder.asset,
                                                amount);

    <a href="LibraAccount.md#0x1_LibraAccount_deposit_libra">LibraAccount::deposit_libra</a>&lt;CoinType&gt;(receiver,
                                          holder.owner,
                                          taken_libra);
}
</code></pre>



</details>
