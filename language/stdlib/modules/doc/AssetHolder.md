
<a name="0x1_AssetHolder"></a>

# Module `0x1::AssetHolder`

### Table of Contents

-  [Resource `AssetHolder`](#0x1_AssetHolder_AssetHolder)
-  [Const `ECANNOT_ADD_TO_OTHERS`](#0x1_AssetHolder_ECANNOT_ADD_TO_OTHERS)
-  [Const `EADD_NON_POSITIVE`](#0x1_AssetHolder_EADD_NON_POSITIVE)
-  [Const `ERECEIVE_NON_POSITIVE`](#0x1_AssetHolder_ERECEIVE_NON_POSITIVE)
-  [Function `zero_issuer_token_holder`](#0x1_AssetHolder_zero_issuer_token_holder)
-  [Function `publish_zero_issuer_token_holder`](#0x1_AssetHolder_publish_zero_issuer_token_holder)
-  [Function `owner`](#0x1_AssetHolder_owner)
-  [Function `borrow_issuer_token_mut`](#0x1_AssetHolder_borrow_issuer_token_mut)
-  [Function `borrow_capability`](#0x1_AssetHolder_borrow_capability)
-  [Function `zero_libra_holder`](#0x1_AssetHolder_zero_libra_holder)
-  [Function `initialize`](#0x1_AssetHolder_initialize)
-  [Function `top_up_libra_holder`](#0x1_AssetHolder_top_up_libra_holder)
-  [Function `receive_libra`](#0x1_AssetHolder_receive_libra)



<a name="0x1_AssetHolder_AssetHolder"></a>

## Resource `AssetHolder`

Resource that is used for distributing IssuerTokens, but also knows
how to distribute Libra. Should never be published directly to an
account, as once loaded by Libra or IssuerTokens, it exposes public
APIs for withdrawal. Instead, it should be wrapped inside the including
module's native struct for access control (hence, the access control
logic is by design detemined by the including module).


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
 TODO: when required, should become a map of id->AssetType, but not
 needed for the current TokenTypes (DefaultToken only uses band_id 0
 and MoneyOrderToken doesn't require holding actual IssuerTokens).
</dd>
<dt>

<code>token_issue_capability: <a href="Option.md#0x1_Option_Option">Option::Option</a>&lt;<a href="TokenIssueCapability.md#0x1_TokenIssueCapability_TokenIssueCapability">TokenIssueCapability::TokenIssueCapability</a>&gt;</code>
</dt>
<dd>
 Some TokenTypes, e.g. MoneyOrderToken, are assumed to be minted &
 available in an infinite amount, and as long as AssetWallet exists
 containing IssuerToken of such a TokenType specialization, any amount
 requested should be withdrawable from the AssetHolder. To implement
 such functionality (without making arbitrary minting possible), a
 capability created by the issuer should be wrapped inside the
 AssetHolder, and only with the Capability the IssuerTokens for a
 given account can be printed (if the caller is not the account).
</dd>
</dl>


</details>

<a name="0x1_AssetHolder_ECANNOT_ADD_TO_OTHERS"></a>

## Const `ECANNOT_ADD_TO_OTHERS`

Adding to non-issuer's AssetHolder.


<pre><code><b>const</b> ECANNOT_ADD_TO_OTHERS: u64 = 0;
</code></pre>



<a name="0x1_AssetHolder_EADD_NON_POSITIVE"></a>

## Const `EADD_NON_POSITIVE`

Adding a non-positive amount.


<pre><code><b>const</b> EADD_NON_POSITIVE: u64 = 1;
</code></pre>



<a name="0x1_AssetHolder_ERECEIVE_NON_POSITIVE"></a>

## Const `ERECEIVE_NON_POSITIVE`

Receiving a non-positive amount.


<pre><code><b>const</b> ERECEIVE_NON_POSITIVE: u64 = 2;
</code></pre>



<a name="0x1_AssetHolder_zero_issuer_token_holder"></a>

## Function `zero_issuer_token_holder`

Returns an AssetHolder holding IssuerToken<TokenType> with both band_id
and amount 0. More complex constructors, when needed should be defined by
the modules declaring individual TokenTypes (similar to how they all
implement the logic for topping up or withdrawing from the assetholders).


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_zero_issuer_token_holder">zero_issuer_token_holder</a>&lt;TokenType&gt;(issuer: &signer, issue_capability: bool): <a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_zero_issuer_token_holder">zero_issuer_token_holder</a>&lt;TokenType&gt;(
    issuer: &signer,
    issue_capability: bool,
): <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt; {
    <b>if</b> (issue_capability) {
        <b>return</b> <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt; {
            owner: <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer),
            asset: <a href="IssuerToken.md#0x1_IssuerToken_mint_issuer_token">IssuerToken::mint_issuer_token</a>&lt;TokenType&gt;(
                issuer,
                0,
                0),
            // Whoever has access <b>to</b> AssetWallet will now have capability
            // <b>to</b> issue <a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;<a href="MoneyOrderToken.md#0x1_MoneyOrderToken">MoneyOrderToken</a>&gt; (specialization id 1)
            // in the issuer's name.
            token_issue_capability: <a href="Option.md#0x1_Option_some">Option::some</a>(
                <a href="TokenIssueCapability.md#0x1_TokenIssueCapability_capability">TokenIssueCapability::capability</a>(issuer, 1))
        }
    };

    <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt; {
        owner: <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer),
        asset: <a href="IssuerToken.md#0x1_IssuerToken_mint_issuer_token">IssuerToken::mint_issuer_token</a>&lt;TokenType&gt;(
            issuer,
            0,
            0),
        token_issue_capability: <a href="Option.md#0x1_Option_none">Option::none</a>&lt;<a href="TokenIssueCapability.md#0x1_TokenIssueCapability">TokenIssueCapability</a>&gt;(),
    }
}
</code></pre>



</details>

<a name="0x1_AssetHolder_publish_zero_issuer_token_holder"></a>

## Function `publish_zero_issuer_token_holder`

This method is public so modules implementing token specializations
(e.g. DefaultToken.move) can publish the structures on the libra root
account during genesis (for type map tracking, CLI display, etc.).


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_publish_zero_issuer_token_holder">publish_zero_issuer_token_holder</a>&lt;TokenType&gt;(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_publish_zero_issuer_token_holder">publish_zero_issuer_token_holder</a>&lt;TokenType&gt;(sender: &signer,
) {
    <a href="LibraTimestamp.md#0x1_LibraTimestamp_assert_genesis">LibraTimestamp::assert_genesis</a>();

    move_to(sender,
            <a href="#0x1_AssetHolder_zero_issuer_token_holder">zero_issuer_token_holder</a>&lt;TokenType&gt;(sender, <b>false</b>));
}
</code></pre>



</details>

<a name="0x1_AssetHolder_owner"></a>

## Function `owner`

Returns the address of AssetHolder's owner, based on the owener field.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_owner">owner</a>&lt;TokenType&gt;(holder: &<a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;&gt;): address
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_owner">owner</a>&lt;TokenType&gt;(holder: &<a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;,
): address {
    holder.owner
}
</code></pre>



</details>

<a name="0x1_AssetHolder_borrow_issuer_token_mut"></a>

## Function `borrow_issuer_token_mut`

Returns mutable reference to the IssuerToken asset.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_borrow_issuer_token_mut">borrow_issuer_token_mut</a>&lt;TokenType&gt;(holder: &<b>mut</b> <a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;&gt;): &<b>mut</b> <a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_borrow_issuer_token_mut">borrow_issuer_token_mut</a>&lt;TokenType&gt;(
    holder: &<b>mut</b> <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;,
): &<b>mut</b> <a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {
    &<b>mut</b> holder.asset
}
</code></pre>



</details>

<a name="0x1_AssetHolder_borrow_capability"></a>

## Function `borrow_capability`

Returns capability stored inside the holder, aborts if there is none.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_borrow_capability">borrow_capability</a>&lt;TokenType&gt;(holder: &<a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;&gt;): &<a href="TokenIssueCapability.md#0x1_TokenIssueCapability_TokenIssueCapability">TokenIssueCapability::TokenIssueCapability</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_borrow_capability">borrow_capability</a>&lt;TokenType&gt;(
    holder: &<a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;,
): &<a href="TokenIssueCapability.md#0x1_TokenIssueCapability">TokenIssueCapability</a> {
    <a href="Option.md#0x1_Option_borrow">Option::borrow</a>&lt;<a href="TokenIssueCapability.md#0x1_TokenIssueCapability">TokenIssueCapability</a>&gt;(&holder.token_issue_capability)
}
</code></pre>



</details>

<a name="0x1_AssetHolder_zero_libra_holder"></a>

## Function `zero_libra_holder`

Returns an AssetHolder holding Libra<CoinType> with 0 value.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_zero_libra_holder">zero_libra_holder</a>&lt;CoinType&gt;(issuer: &signer): <a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="Libra.md#0x1_Libra_Libra">Libra::Libra</a>&lt;CoinType&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_zero_libra_holder">zero_libra_holder</a>&lt;CoinType&gt;(issuer: &signer
): <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="Libra.md#0x1_Libra">Libra</a>&lt;CoinType&gt;&gt; {
    <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="Libra.md#0x1_Libra">Libra</a>&lt;CoinType&gt;&gt; {
        owner: <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer),
        asset: <a href="Libra.md#0x1_Libra_zero">Libra::zero</a>&lt;CoinType&gt;(),
        token_issue_capability: <a href="Option.md#0x1_Option_none">Option::none</a>&lt;<a href="TokenIssueCapability.md#0x1_TokenIssueCapability">TokenIssueCapability</a>&gt;(),
        // token_issue capability is irrelevant here, set <b>to</b> none.
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

    // Publish for <a href="Libra.md#0x1_Libra">Libra</a> types (<a href="IssuerToken.md#0x1_IssuerToken">IssuerToken</a> types publish
    // in their initialize).
    move_to(lr_account, <a href="#0x1_AssetHolder_zero_libra_holder">zero_libra_holder</a>&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;(lr_account));
    move_to(lr_account, <a href="#0x1_AssetHolder_zero_libra_holder">zero_libra_holder</a>&lt;<a href="Coin2.md#0x1_Coin2">Coin2</a>&gt;(lr_account));
    move_to(lr_account, <a href="#0x1_AssetHolder_zero_libra_holder">zero_libra_holder</a>&lt;<a href="LBR.md#0x1_LBR">LBR</a>&gt;(lr_account));
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
    <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer) == holder.owner,
           <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(ECANNOT_ADD_TO_OTHERS));
    // Top up amount should be positive.
    <b>assert</b>(amount &gt; 0,
           <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(EADD_NON_POSITIVE));

    <a href="Libra.md#0x1_Libra_deposit">Libra::deposit</a>&lt;CoinType&gt;(
        &<b>mut</b> holder.asset,
        <a href="LibraAccount.md#0x1_LibraAccount_withdraw_libra">LibraAccount::withdraw_libra</a>(issuer, amount));
}
</code></pre>



</details>

<a name="0x1_AssetHolder_receive_libra"></a>

## Function `receive_libra`

Takes Libra<CoinType> from the AssetHolder and deposits on
receivers account balance.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_receive_libra">receive_libra</a>&lt;CoinType&gt;(receiver: &signer, holder: &<b>mut</b> <a href="#0x1_AssetHolder_AssetHolder">AssetHolder::AssetHolder</a>&lt;<a href="Libra.md#0x1_Libra_Libra">Libra::Libra</a>&lt;CoinType&gt;&gt;, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_AssetHolder_receive_libra">receive_libra</a>&lt;CoinType&gt;(
    receiver: &signer,
    holder: &<b>mut</b> <a href="#0x1_AssetHolder">AssetHolder</a>&lt;<a href="Libra.md#0x1_Libra">Libra</a>&lt;CoinType&gt;&gt;,
    amount: u64,
) {
    // Received amount should be positive.
    <b>assert</b>(amount &gt; 0,
           <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(ERECEIVE_NON_POSITIVE));

    <b>let</b> taken_libra = <a href="Libra.md#0x1_Libra_withdraw">Libra::withdraw</a>&lt;CoinType&gt;(&<b>mut</b> holder.asset,
                                                amount);

    <a href="LibraAccount.md#0x1_LibraAccount_deposit_libra">LibraAccount::deposit_libra</a>&lt;CoinType&gt;(receiver,
                                          holder.owner,
                                          taken_libra);
}
</code></pre>



</details>
