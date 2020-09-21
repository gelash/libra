
<a name="0x1_DefaultToken"></a>

# Module `0x1::DefaultToken`

### Table of Contents

-  [Struct `DefaultToken`](#0x1_DefaultToken_DefaultToken)
-  [Const `ECANNOT_ADD_TO_OTHERS`](#0x1_DefaultToken_ECANNOT_ADD_TO_OTHERS)
-  [Const `EADD_NON_POSITIVE`](#0x1_DefaultToken_EADD_NON_POSITIVE)
-  [Const `ERECEIVE_NON_POSITIVE`](#0x1_DefaultToken_ERECEIVE_NON_POSITIVE)
-  [Function `initialize`](#0x1_DefaultToken_initialize)
-  [Function `asset_holder_top_up`](#0x1_DefaultToken_asset_holder_top_up)
-  [Function `asset_holder_withdraw`](#0x1_DefaultToken_asset_holder_withdraw)



<a name="0x1_DefaultToken_DefaultToken"></a>

## Struct `DefaultToken`

Default empty info struct for templating IssuerToken on, i.e. having
different specializations of the same issuer token functionality.
By convention, DefaultToken won't make use of IssuerToken's 'band'
functionality (i.e. band_id will always be set to 0).


<pre><code><b>struct</b> <a href="#0x1_DefaultToken">DefaultToken</a>
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

<a name="0x1_DefaultToken_ECANNOT_ADD_TO_OTHERS"></a>

## Const `ECANNOT_ADD_TO_OTHERS`

Adding IssuerToken to non-issuer's AssetHolder


<pre><code><b>const</b> ECANNOT_ADD_TO_OTHERS: u64 = 0;
</code></pre>



<a name="0x1_DefaultToken_EADD_NON_POSITIVE"></a>

## Const `EADD_NON_POSITIVE`

Adding IssuerToken with non-positive amount


<pre><code><b>const</b> EADD_NON_POSITIVE: u64 = 1;
</code></pre>



<a name="0x1_DefaultToken_ERECEIVE_NON_POSITIVE"></a>

## Const `ERECEIVE_NON_POSITIVE`

Receiving IssuerToken with non-positive amount


<pre><code><b>const</b> ERECEIVE_NON_POSITIVE: u64 = 2;
</code></pre>



<a name="0x1_DefaultToken_initialize"></a>

## Function `initialize`

Can only be called during genesis with libra root account.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_DefaultToken_initialize">initialize</a>(lr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_DefaultToken_initialize">initialize</a>(lr_account: &signer) {
    <a href="LibraTimestamp.md#0x1_LibraTimestamp_assert_genesis">LibraTimestamp::assert_genesis</a>();

    <a href="AssetHolder.md#0x1_AssetHolder_publish_zero_issuer_token_holder">AssetHolder::publish_zero_issuer_token_holder</a>&lt;<a href="#0x1_DefaultToken">DefaultToken</a>&gt;(
        lr_account);

    <a href="IssuerToken.md#0x1_IssuerToken_publish_issuer_token_container">IssuerToken::publish_issuer_token_container</a>&lt;<a href="#0x1_DefaultToken">DefaultToken</a>&gt;(
        lr_account);
    <a href="IssuerToken.md#0x1_IssuerToken_register_token_specialization">IssuerToken::register_token_specialization</a>&lt;<a href="#0x1_DefaultToken">DefaultToken</a>&gt;(
        lr_account, 0);
}
</code></pre>



</details>

<a name="0x1_DefaultToken_asset_holder_top_up"></a>

## Function `asset_holder_top_up`

Adds IssuerToken<DefaultToken> to the AssetHolder. Asserts that
the AssetHolder's owner is the issuer.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_DefaultToken_asset_holder_top_up">asset_holder_top_up</a>(issuer: &signer, holder: &<b>mut</b> <a href="AssetHolder.md#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;<a href="#0x1_DefaultToken_DefaultToken">DefaultToken::DefaultToken</a>&gt;&gt;, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_DefaultToken_asset_holder_top_up">asset_holder_top_up</a>(
    issuer: &signer,
    holder: &<b>mut</b> <a href="AssetHolder.md#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;<a href="#0x1_DefaultToken">DefaultToken</a>&gt;&gt;,
    amount: u64,
) {
    // Issuer should be the holder's owner.
    <b>assert</b>(
        <a href="AssetHolder.md#0x1_AssetHolder_owner">AssetHolder::owner</a>&lt;<a href="#0x1_DefaultToken">DefaultToken</a>&gt;(holder) ==
            <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer),
        <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(ECANNOT_ADD_TO_OTHERS));
    // Top up amount should be positive.
    <b>assert</b>(amount &gt; 0,
           <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(EADD_NON_POSITIVE));

    <a href="IssuerToken.md#0x1_IssuerToken_merge_issuer_token">IssuerToken::merge_issuer_token</a>&lt;<a href="#0x1_DefaultToken">DefaultToken</a>&gt;(
        <a href="AssetHolder.md#0x1_AssetHolder_borrow_issuer_token_mut">AssetHolder::borrow_issuer_token_mut</a>&lt;<a href="#0x1_DefaultToken">DefaultToken</a>&gt;(holder),
        <a href="IssuerToken.md#0x1_IssuerToken_mint_issuer_token">IssuerToken::mint_issuer_token</a>&lt;<a href="#0x1_DefaultToken">DefaultToken</a>&gt;(issuer,
                                                     0, // band_id = 0
                                                     amount));
}
</code></pre>



</details>

<a name="0x1_DefaultToken_asset_holder_withdraw"></a>

## Function `asset_holder_withdraw`

Takes IssuerToken<DefaultToken> from the AssetHolder and deposits
on receivers account (stored in the IssuerTokenContainer struct).


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_DefaultToken_asset_holder_withdraw">asset_holder_withdraw</a>(receiver: &signer, holder: &<b>mut</b> <a href="AssetHolder.md#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;<a href="#0x1_DefaultToken_DefaultToken">DefaultToken::DefaultToken</a>&gt;&gt;, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_DefaultToken_asset_holder_withdraw">asset_holder_withdraw</a>(
    receiver: &signer,
    holder: &<b>mut</b> <a href="AssetHolder.md#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;<a href="#0x1_DefaultToken">DefaultToken</a>&gt;&gt;,
    amount: u64,
) {
    // Received amount should be positive.
    <b>assert</b>(amount &gt; 0,
           <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(ERECEIVE_NON_POSITIVE));

    <b>let</b> issuer_tokens =
        <a href="IssuerToken.md#0x1_IssuerToken_split_issuer_token">IssuerToken::split_issuer_token</a>&lt;<a href="#0x1_DefaultToken">DefaultToken</a>&gt;(
            <a href="AssetHolder.md#0x1_AssetHolder_borrow_issuer_token_mut">AssetHolder::borrow_issuer_token_mut</a>&lt;<a href="#0x1_DefaultToken">DefaultToken</a>&gt;(
                holder),
            amount);

    // This call also asserts that receiver != issuer.
    <a href="IssuerToken.md#0x1_IssuerToken_deposit_issuer_token">IssuerToken::deposit_issuer_token</a>&lt;<a href="#0x1_DefaultToken">DefaultToken</a>&gt;(receiver,
                                                    issuer_tokens);
}
</code></pre>



</details>
