
<a name="0x1_AssetHolder"></a>

# Module `0x1::AssetHolder`

### Table of Contents

-  [Resource `AssetHolder`](#0x1_AssetHolder_AssetHolder)
-  [Function `create_default_issuer_token_holder`](#0x1_AssetHolder_create_default_issuer_token_holder)
-  [Function `initialize`](#0x1_AssetHolder_initialize)
-  [Function `top_up_default_issuer_token_holder`](#0x1_AssetHolder_top_up_default_issuer_token_holder)
-  [Function `deposit_default_issuer_token`](#0x1_AssetHolder_deposit_default_issuer_token)



<a name="0x1_AssetHolder_AssetHolder"></a>

## Resource `AssetHolder`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_AssetHolder">AssetHolder</a>&lt;AssetType&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>asset: AssetType</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_AssetHolder_create_default_issuer_token_holder"></a>

## Function `create_default_issuer_token_holder`

Returns an AssetHolder holding IssuerToken<DefaultToken> with
amount = starting_amount. Note: Band for DefaultToken is always 0.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_create_default_issuer_token_holder">create_default_issuer_token_holder</a>(issuer: &signer, starting_amount: u64): <a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_DefaultToken">IssuerToken::DefaultToken</a>&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_create_default_issuer_token_holder">create_default_issuer_token_holder</a>(
    issuer: &signer,
    starting_amount: u64,
): <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;DefaultToken&gt;&gt; {
    <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;DefaultToken&gt;&gt; {
        asset: <a href="IssuerToken.md#0x1_IssuerToken_mint_issuer_token">IssuerToken::mint_issuer_token</a>&lt;DefaultToken&gt;(
            issuer,
            0,
            starting_amount)
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
            <a href="#0x1_AssetHolder_create_default_issuer_token_holder">create_default_issuer_token_holder</a>(lr_account, 0));
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
    // TODO: maybe <b>assert</b> that it's for holder is for the same issuer.
    <a href="IssuerToken.md#0x1_IssuerToken_merge_issuer_token">IssuerToken::merge_issuer_token</a>&lt;DefaultToken&gt;(
        &<b>mut</b> holder.asset,
        <a href="IssuerToken.md#0x1_IssuerToken_mint_issuer_token">IssuerToken::mint_issuer_token</a>&lt;DefaultToken&gt;(issuer,
                                                     0,
                                                     amount));
}
</code></pre>



</details>

<a name="0x1_AssetHolder_deposit_default_issuer_token"></a>

## Function `deposit_default_issuer_token`

Takes IssuerToken<DefaultToken> from the AssetHolder on issuer's
account and deposits on receivers account (stored in IssuerTokens
struct). Note: For now, band for DefaultToken is always 0.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_deposit_default_issuer_token">deposit_default_issuer_token</a>(receiver: &signer, holder: &<b>mut</b> <a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_DefaultToken">IssuerToken::DefaultToken</a>&gt;&gt;, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_deposit_default_issuer_token">deposit_default_issuer_token</a>(
    receiver: &signer,
    holder: &<b>mut</b> <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;DefaultToken&gt;&gt;,
    amount: u64,
) {
    <b>let</b> issuer_tokens =
        <a href="IssuerToken.md#0x1_IssuerToken_split_issuer_token">IssuerToken::split_issuer_token</a>&lt;DefaultToken&gt;(&<b>mut</b> holder.asset,
                                                      amount);

    // This call also asserts that receiver != issuer
    <a href="IssuerToken.md#0x1_IssuerToken_deposit_issuer_token">IssuerToken::deposit_issuer_token</a>&lt;DefaultToken&gt;(receiver,
                                                    issuer_tokens);
}
</code></pre>



</details>
