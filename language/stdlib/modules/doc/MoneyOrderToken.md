
<a name="0x1_MoneyOrderToken"></a>

# Module `0x1::MoneyOrderToken`

### Table of Contents

-  [Struct `MoneyOrderToken`](#0x1_MoneyOrderToken_MoneyOrderToken)
-  [Const `ERECEIVE_NON_POSITIVE`](#0x1_MoneyOrderToken_ERECEIVE_NON_POSITIVE)
-  [Function `initialize`](#0x1_MoneyOrderToken_initialize)
-  [Function `asset_holder_withdraw`](#0x1_MoneyOrderToken_asset_holder_withdraw)



<a name="0x1_MoneyOrderToken_MoneyOrderToken"></a>

## Struct `MoneyOrderToken`

Empty struct that's used for money orders issuer token functionality.
Makes use of the 'band' feature of the IssuerToken for distinguishing
tokens issued for different batches of money orders (Side note:
when that's not required, DefaultToken can be used instead).


<pre><code><b>struct</b> <a href="#0x1_MoneyOrderToken">MoneyOrderToken</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MoneyOrderToken_ERECEIVE_NON_POSITIVE"></a>

## Const `ERECEIVE_NON_POSITIVE`

Receiving IssuerToken with non-positive amount


<pre><code><b>const</b> ERECEIVE_NON_POSITIVE: u64 = 0;
</code></pre>



<a name="0x1_MoneyOrderToken_initialize"></a>

## Function `initialize`

Can only be called during genesis with libra root account.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrderToken_initialize">initialize</a>(lr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrderToken_initialize">initialize</a>(lr_account: &signer) {
    <a href="LibraTimestamp.md#0x1_LibraTimestamp_assert_genesis">LibraTimestamp::assert_genesis</a>();

    <a href="AssetHolder.md#0x1_AssetHolder_publish_zero_issuer_token_holder">AssetHolder::publish_zero_issuer_token_holder</a>&lt;<a href="#0x1_MoneyOrderToken">MoneyOrderToken</a>&gt;(
        lr_account);

    <a href="IssuerToken.md#0x1_IssuerToken_publish_issuer_token_container">IssuerToken::publish_issuer_token_container</a>&lt;<a href="#0x1_MoneyOrderToken">MoneyOrderToken</a>&gt;(
        lr_account);
    <a href="IssuerToken.md#0x1_IssuerToken_register_token_specialization">IssuerToken::register_token_specialization</a>&lt;<a href="#0x1_MoneyOrderToken">MoneyOrderToken</a>&gt;(
        lr_account, 1);
}
</code></pre>



</details>

<a name="0x1_MoneyOrderToken_asset_holder_withdraw"></a>

## Function `asset_holder_withdraw`

Issue the specified amount of MoneyOrderTokens of the AssetHolder's
owner with band_id = batch_index and deposit it to the receiver.
The caller of this function (e.g. MoneyOrder module) must have
granted the access. Cannot be used to produce extra tokens because
the issuer's AssetHolder should never be exposed for direct access
(e.g. MoneyOrder module wraps it inside the MoneyOrderAssetHolder
resource and access controls).


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrderToken_asset_holder_withdraw">asset_holder_withdraw</a>(receiver: &signer, holder: &<b>mut</b> <a href="AssetHolder.md#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;<a href="#0x1_MoneyOrderToken_MoneyOrderToken">MoneyOrderToken::MoneyOrderToken</a>&gt;&gt;, batch_index: u64, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrderToken_asset_holder_withdraw">asset_holder_withdraw</a>(
    receiver: &signer,
    holder: &<b>mut</b> <a href="AssetHolder.md#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;<a href="#0x1_MoneyOrderToken">MoneyOrderToken</a>&gt;&gt;,
    batch_index: u64,
    amount: u64,
) {
    // Received amount should be positive.
    <b>assert</b>(amount &gt; 0,
           <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(ERECEIVE_NON_POSITIVE));

    <b>let</b> issuer_tokens =
        <a href="IssuerToken.md#0x1_IssuerToken_mint_issuer_token_with_capability">IssuerToken::mint_issuer_token_with_capability</a>&lt;<a href="#0x1_MoneyOrderToken">MoneyOrderToken</a>&gt;(
            <a href="AssetHolder.md#0x1_AssetHolder_borrow_capability">AssetHolder::borrow_capability</a>&lt;<a href="#0x1_MoneyOrderToken">MoneyOrderToken</a>&gt;(holder),
            <a href="AssetHolder.md#0x1_AssetHolder_owner">AssetHolder::owner</a>&lt;<a href="#0x1_MoneyOrderToken">MoneyOrderToken</a>&gt;(holder),
            batch_index,
            amount);

    // This call also asserts that receiver != issuer.
    <a href="IssuerToken.md#0x1_IssuerToken_deposit_issuer_token">IssuerToken::deposit_issuer_token</a>&lt;<a href="#0x1_MoneyOrderToken">MoneyOrderToken</a>&gt;(receiver,
                                                       issuer_tokens);
}
</code></pre>



</details>
