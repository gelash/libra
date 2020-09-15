
<a name="0x1_IssuerToken"></a>

# Module `0x1::IssuerToken`

### Table of Contents

-  [Struct `DefaultToken`](#0x1_IssuerToken_DefaultToken)
-  [Struct `MoneyOrderToken`](#0x1_IssuerToken_MoneyOrderToken)
-  [Struct `BurnIssuerTokenEvent`](#0x1_IssuerToken_BurnIssuerTokenEvent)
-  [Resource `IssuerToken`](#0x1_IssuerToken_IssuerToken)
-  [Resource `IssuerTokenContainer`](#0x1_IssuerToken_IssuerTokenContainer)
-  [Const `EDEPOSIT_EXCEEDS_LIMITS`](#0x1_IssuerToken_EDEPOSIT_EXCEEDS_LIMITS)
-  [Const `ESELF_DEPOSIT`](#0x1_IssuerToken_ESELF_DEPOSIT)
-  [Const `EILLEGAL_MERGE`](#0x1_IssuerToken_EILLEGAL_MERGE)
-  [Const `EBURN_NON_POS`](#0x1_IssuerToken_EBURN_NON_POS)
-  [Const `EMISSING_CONTAINER`](#0x1_IssuerToken_EMISSING_CONTAINER)
-  [Const `EISSUER_TOKEN_NOT_FOUND`](#0x1_IssuerToken_EISSUER_TOKEN_NOT_FOUND)
-  [Const `EBURN_EXCEEDS_LIMITS`](#0x1_IssuerToken_EBURN_EXCEEDS_LIMITS)
-  [Function `publish_issuer_tokens`](#0x1_IssuerToken_publish_issuer_tokens)
-  [Function `initialize`](#0x1_IssuerToken_initialize)
-  [Function `find_issuer_token`](#0x1_IssuerToken_find_issuer_token)
-  [Function `create_issuer_token`](#0x1_IssuerToken_create_issuer_token)
-  [Function `mint_issuer_token`](#0x1_IssuerToken_mint_issuer_token)
-  [Function `merge_issuer_token`](#0x1_IssuerToken_merge_issuer_token)
-  [Function `split_issuer_token`](#0x1_IssuerToken_split_issuer_token)
-  [Function `value`](#0x1_IssuerToken_value)
-  [Function `issuer_token_balance`](#0x1_IssuerToken_issuer_token_balance)
-  [Function `deposit_issuer_token`](#0x1_IssuerToken_deposit_issuer_token)
-  [Function `burn_issuer_token`](#0x1_IssuerToken_burn_issuer_token)
-  [Function `burn_to_issuer`](#0x1_IssuerToken_burn_to_issuer)
-  [Function `burn_all_to_issuer`](#0x1_IssuerToken_burn_all_to_issuer)
-  [Function `burn_all_issuer_default_tokens`](#0x1_IssuerToken_burn_all_issuer_default_tokens)
-  [Function `burn_issuer_default_tokens`](#0x1_IssuerToken_burn_issuer_default_tokens)



<a name="0x1_IssuerToken_DefaultToken"></a>

## Struct `DefaultToken`

Default empty info struct for templating IssuerToken on, i.e. having
different specializations of the same issuer token functionality.
By convention, DefaultToken won't make use of IssuerToken's 'band'
functionality (i.e. band_id will always be set to 0).


<pre><code><b>struct</b> <a href="#0x1_IssuerToken_DefaultToken">DefaultToken</a>
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

<a name="0x1_IssuerToken_MoneyOrderToken"></a>

## Struct `MoneyOrderToken`

Empty struct that's used for money orders issuer token functionality.
Makes use of the 'band' feature of the IssuerToken for distinguishing
tokens issued for different batches of money orders (Side note:
when that's not required, DefaultToken can be used instead).


<pre><code><b>struct</b> <a href="#0x1_IssuerToken_MoneyOrderToken">MoneyOrderToken</a>
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

<a name="0x1_IssuerToken_BurnIssuerTokenEvent"></a>

## Struct `BurnIssuerTokenEvent`

BurnIssuerTokenEvents when emitted, serve as a unique certificate
for the burnt amount of the specified issuer token type - since once
an amount is burnt, it's subtracted from the available amount.


<pre><code><b>struct</b> <a href="#0x1_IssuerToken_BurnIssuerTokenEvent">BurnIssuerTokenEvent</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>specialization_id: u8</code>
</dt>
<dd>
 Information identifying the issuer token. 'specialization_id' is
 a byte that specifies the what <TokenType> parameter was used
 according to a fixed convention (currently, we use the declaration
 order in this module, e.g. DefaultToken is 0, MoneyOrderToken is 1).
</dd>
<dt>

<code>issuer_address: address</code>
</dt>
<dd>

</dd>
<dt>

<code>band_id: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>burnt_amount: u64</code>
</dt>
<dd>
 Amount of the IssuerTokens that was burnt.
</dd>
</dl>


</details>

<a name="0x1_IssuerToken_IssuerToken"></a>

## Resource `IssuerToken`

The main IssuerToken wrapper resource. Shouldn't be stored on accounts
directly, but rather be wrapped inside IssuerTokenContainer for tokens
issued by other accounts, and BalanceHolder for distributing tokens
issued by the holding account. Once distributed, issuer tokens should
never go back to issuer, they can only be 'burned' back to the issuer.
Note: DefaultToken specialization uses a single band.


<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>issuer_address: address</code>
</dt>
<dd>
 The issuer is the only entity that can authorize issuing these
 tokens (by directly calling, or manual cryptographic guarantees).
</dd>
<dt>

<code>band_id: u64</code>
</dt>
<dd>
 issuer tokens of the same type but different bands can be
 treated as different tokens, hence, allowing issuers to issue
 differently "typed" tokens at runtime, when needed.
</dd>
<dt>

<code>amount: u64</code>
</dt>
<dd>
 the amount of stored issuer tokens (of the specified type and band).
</dd>
</dl>


</details>

<a name="0x1_IssuerToken_IssuerTokenContainer"></a>

## Resource `IssuerTokenContainer`

Container for holding redeemed issuer tokens on accounts (i.e.
on accounts other than the issuer).


<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;IssuerTokenType&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>issuer_tokens: vector&lt;IssuerTokenType&gt;</code>
</dt>
<dd>

</dd>
<dt>

<code>burn_events: <a href="Event.md#0x1_Event_EventHandle">Event::EventHandle</a>&lt;<a href="#0x1_IssuerToken_BurnIssuerTokenEvent">IssuerToken::BurnIssuerTokenEvent</a>&gt;</code>
</dt>
<dd>
 Event stream for burning IssuerTokens (where BurnIssuerTokenEvents
 are emitted).
</dd>
</dl>


</details>

<a name="0x1_IssuerToken_EDEPOSIT_EXCEEDS_LIMITS"></a>

## Const `EDEPOSIT_EXCEEDS_LIMITS`

Trying to deposit funds that would have surpassed the account's limits


<pre><code><b>const</b> EDEPOSIT_EXCEEDS_LIMITS: u64 = 0;
</code></pre>



<a name="0x1_IssuerToken_ESELF_DEPOSIT"></a>

## Const `ESELF_DEPOSIT`

Issuer depositing own coins on its account (in IssuerTokenContainer structure).


<pre><code><b>const</b> ESELF_DEPOSIT: u64 = 1;
</code></pre>



<a name="0x1_IssuerToken_EILLEGAL_MERGE"></a>

## Const `EILLEGAL_MERGE`

Trying to merge different issuer tokens.


<pre><code><b>const</b> EILLEGAL_MERGE: u64 = 2;
</code></pre>



<a name="0x1_IssuerToken_EBURN_NON_POS"></a>

## Const `EBURN_NON_POS`

A burn was attempted with non-positive amount


<pre><code><b>const</b> EBURN_NON_POS: u64 = 3;
</code></pre>



<a name="0x1_IssuerToken_EMISSING_CONTAINER"></a>

## Const `EMISSING_CONTAINER`

A burn of IssuerToken<TokenType>> was attempted from non-existing matching IssuerTokenContainer


<pre><code><b>const</b> EMISSING_CONTAINER: u64 = 4;
</code></pre>



<a name="0x1_IssuerToken_EISSUER_TOKEN_NOT_FOUND"></a>

## Const `EISSUER_TOKEN_NOT_FOUND`

Could not find issuer token based on address


<pre><code><b>const</b> EISSUER_TOKEN_NOT_FOUND: u64 = 5;
</code></pre>



<a name="0x1_IssuerToken_EBURN_EXCEEDS_LIMITS"></a>

## Const `EBURN_EXCEEDS_LIMITS`

Trying to burn funds that would have surpassed the account's limits


<pre><code><b>const</b> EBURN_EXCEEDS_LIMITS: u64 = 6;
</code></pre>



<a name="0x1_IssuerToken_publish_issuer_tokens"></a>

## Function `publish_issuer_tokens`

Publishes the IssuerTokenContainer struct on sender's account, allowing it
to hold tokens of IssuerTokenType issued by other accounts.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_publish_issuer_tokens">publish_issuer_tokens</a>&lt;IssuerTokenType&gt;(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_publish_issuer_tokens">publish_issuer_tokens</a>&lt;IssuerTokenType&gt;(sender: &signer) {
    <b>let</b> sender_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);

    <b>if</b> (!exists&lt;<a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;IssuerTokenType&gt;&gt;(sender_address)) {
        move_to(sender, <a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;IssuerTokenType&gt; {
            issuer_tokens: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
            burn_events: <a href="Event.md#0x1_Event_new_event_handle">Event::new_event_handle</a>&lt;<a href="#0x1_IssuerToken_BurnIssuerTokenEvent">BurnIssuerTokenEvent</a>&gt;(sender)
        });
    };
}
</code></pre>



</details>

<a name="0x1_IssuerToken_initialize"></a>

## Function `initialize`

Can only be called during genesis with libra root account.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_initialize">initialize</a>(lr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_initialize">initialize</a>(lr_account: &signer) {
    <a href="LibraTimestamp.md#0x1_LibraTimestamp_assert_genesis">LibraTimestamp::assert_genesis</a>();

    // Publish for existing <a href="#0x1_IssuerToken">IssuerToken</a> types.
    <a href="#0x1_IssuerToken_publish_issuer_tokens">publish_issuer_tokens</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;<a href="#0x1_IssuerToken_DefaultToken">DefaultToken</a>&gt;&gt;(lr_account);
    <a href="#0x1_IssuerToken_publish_issuer_tokens">publish_issuer_tokens</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;<a href="#0x1_IssuerToken_MoneyOrderToken">MoneyOrderToken</a>&gt;&gt;(lr_account);
}
</code></pre>



</details>

<a name="0x1_IssuerToken_find_issuer_token"></a>

## Function `find_issuer_token`



<pre><code><b>fun</b> <a href="#0x1_IssuerToken_find_issuer_token">find_issuer_token</a>&lt;TokenType&gt;(issuer_token_vector: &vector&lt;<a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;&gt;, issuer_address: address, band_id: u64): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_IssuerToken_find_issuer_token">find_issuer_token</a>&lt;TokenType&gt;(
    issuer_token_vector: &vector&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;,
    issuer_address: address,
    band_id: u64,
): (bool, u64) {
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="Vector.md#0x1_Vector_length">Vector::length</a>(issuer_token_vector)) {
        <b>let</b> token = <a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(issuer_token_vector, i);
        <b>if</b> (token.issuer_address == issuer_address &&
            token.band_id == band_id) {
            <b>return</b> (<b>true</b>, i)
        };

        i = i + 1;
    };
    (<b>false</b>, 0)
}
</code></pre>



</details>

<a name="0x1_IssuerToken_create_issuer_token"></a>

## Function `create_issuer_token`



<pre><code><b>fun</b> <a href="#0x1_IssuerToken_create_issuer_token">create_issuer_token</a>&lt;TokenType&gt;(issuer_address: address, band_id: u64, amount: u64): <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_IssuerToken_create_issuer_token">create_issuer_token</a>&lt;TokenType&gt;(issuer_address: address,
                                   band_id: u64,
                                   amount: u64,
): <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {
    <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {
        issuer_address: issuer_address,
        band_id: band_id,
        amount: amount,
    }
}
</code></pre>



</details>

<a name="0x1_IssuerToken_mint_issuer_token"></a>

## Function `mint_issuer_token`

Sender can mint arbitrary amounts of its own IssuerToken (with own address).


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_mint_issuer_token">mint_issuer_token</a>&lt;TokenType&gt;(issuer: &signer, band_id: u64, amount: u64): <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_mint_issuer_token">mint_issuer_token</a>&lt;TokenType&gt;(issuer: &signer,
                                        band_id: u64,
                                        amount: u64,
): <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {
    <b>let</b> issuer_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer);

    <a href="#0x1_IssuerToken_create_issuer_token">create_issuer_token</a>&lt;TokenType&gt;(issuer_address, band_id, amount)
}
</code></pre>



</details>

<a name="0x1_IssuerToken_merge_issuer_token"></a>

## Function `merge_issuer_token`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_merge_issuer_token">merge_issuer_token</a>&lt;TokenType&gt;(issuer_token_a: &<b>mut</b> <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;, issuer_token_b: <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_merge_issuer_token">merge_issuer_token</a>&lt;TokenType&gt;(
    issuer_token_a: &<b>mut</b> <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;,
    issuer_token_b: <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;,
) {
    <b>let</b> <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; { issuer_address,
                                 band_id,
                                 amount } = issuer_token_b;

    <b>assert</b>(issuer_token_a.issuer_address == issuer_address, <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(EILLEGAL_MERGE));
    <b>assert</b>(issuer_token_a.band_id == band_id, <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(EILLEGAL_MERGE));

    <b>let</b> token_amount = &<b>mut</b> issuer_token_a.amount;
    *token_amount = *token_amount + amount;
}
</code></pre>



</details>

<a name="0x1_IssuerToken_split_issuer_token"></a>

## Function `split_issuer_token`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_split_issuer_token">split_issuer_token</a>&lt;TokenType&gt;(issuer_token: &<b>mut</b> <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;, amount: u64): <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_split_issuer_token">split_issuer_token</a>&lt;TokenType&gt;(
    issuer_token: &<b>mut</b> <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;,
    amount: u64,
): <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {
    <b>assert</b>(issuer_token.amount &gt;= amount, <a href="Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(EDEPOSIT_EXCEEDS_LIMITS));
    <b>let</b> token_amount = &<b>mut</b> issuer_token.amount;
    *token_amount = *token_amount - amount;

    <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {
        issuer_address: issuer_token.issuer_address,
        band_id: issuer_token.band_id,
        amount: amount,
    }
}
</code></pre>



</details>

<a name="0x1_IssuerToken_value"></a>

## Function `value`

Returns the
<code>amount</code> of the passed in
<code>issuer_token</code>.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_value">value</a>&lt;TokenType&gt;(issuer_token: &<a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_value">value</a>&lt;TokenType&gt;(issuer_token: &<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;): u64 {
    issuer_token.amount
}
</code></pre>



</details>

<a name="0x1_IssuerToken_issuer_token_balance"></a>

## Function `issuer_token_balance`

Returns the balance of a particular IssuerToken type (determined by the
TokenType specialization, issuer_address and band_id) on senders account
(in its IssuerTokenContainer to be precise). If the container doesn't exist
or contain the type of IssuerToken, value 0 is returned.
Note: One of the primary uses of this function is for the unit tests.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_issuer_token_balance">issuer_token_balance</a>&lt;TokenType&gt;(sender: &signer, issuer_address: address, band_id: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_issuer_token_balance">issuer_token_balance</a>&lt;TokenType&gt;(sender: &signer,
                                           issuer_address: address,
                                           band_id: u64,
): u64 <b>acquires</b> <a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a> {
    <b>let</b> sender_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
    <b>if</b> (!exists&lt;<a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(sender_address)) {
        <b>return</b> 0
    };
    <b>let</b> sender_tokens =
        borrow_global&lt;<a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(sender_address);

    <b>let</b> (found, target_index) =
        <a href="#0x1_IssuerToken_find_issuer_token">find_issuer_token</a>&lt;TokenType&gt;(&sender_tokens.issuer_tokens,
                                     issuer_address,
                                     band_id);
    <b>if</b> (!found) <b>return</b> 0;

    <b>let</b> issuer_token = <a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&sender_tokens.issuer_tokens, target_index);
    issuer_token.amount
}
</code></pre>



</details>

<a name="0x1_IssuerToken_deposit_issuer_token"></a>

## Function `deposit_issuer_token`

Deposits the issuer token in the IssuerTokenContainer structure on receiver's account.
It's asserted that receiver != issuer, and IssuerTokenContainer<TokenType> is created
if not already published on the receiver's account.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_deposit_issuer_token">deposit_issuer_token</a>&lt;TokenType&gt;(receiver: &signer, issuer_token: <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_deposit_issuer_token">deposit_issuer_token</a>&lt;TokenType&gt;(receiver: &signer,
                                           issuer_token: <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;,
) <b>acquires</b> <a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a> {
    <b>let</b> receiver_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(receiver);
    <b>assert</b>(issuer_token.issuer_address != receiver_address, <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(ESELF_DEPOSIT));

    <b>if</b> (!exists&lt;<a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(receiver_address)) {
        <a href="#0x1_IssuerToken_publish_issuer_tokens">publish_issuer_tokens</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;(receiver);
    };
    <b>let</b> receiver_tokens =
        borrow_global_mut&lt;<a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(receiver_address);

    <b>let</b> (found, target_index) =
        <a href="#0x1_IssuerToken_find_issuer_token">find_issuer_token</a>&lt;TokenType&gt;(&receiver_tokens.issuer_tokens,
                                     issuer_token.issuer_address,
                                     issuer_token.band_id);
    <b>if</b> (!found) {
        // If a issuer token with given type and band_id is not stored,
        // store one with 0 amount.
        target_index = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&receiver_tokens.issuer_tokens);
        <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> receiver_tokens.issuer_tokens,
                          <a href="#0x1_IssuerToken_create_issuer_token">create_issuer_token</a>&lt;TokenType&gt;(
                              issuer_token.issuer_address,
                              issuer_token.band_id,
                              0));
    };

    // Actually increment the issuer token amount.
    <a href="#0x1_IssuerToken_merge_issuer_token">merge_issuer_token</a>(<a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> receiver_tokens.issuer_tokens,
                                          target_index),
                       issuer_token);
}
</code></pre>



</details>

<a name="0x1_IssuerToken_burn_issuer_token"></a>

## Function `burn_issuer_token`



<pre><code><b>fun</b> <a href="#0x1_IssuerToken_burn_issuer_token">burn_issuer_token</a>&lt;TokenType&gt;(to_burn_token: <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;, event_handle: &<b>mut</b> <a href="Event.md#0x1_Event_EventHandle">Event::EventHandle</a>&lt;<a href="#0x1_IssuerToken_BurnIssuerTokenEvent">IssuerToken::BurnIssuerTokenEvent</a>&gt;, specialization_id: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_IssuerToken_burn_issuer_token">burn_issuer_token</a>&lt;TokenType&gt;(to_burn_token: <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;,
                                 event_handle: &<b>mut</b> EventHandle&lt;<a href="#0x1_IssuerToken_BurnIssuerTokenEvent">BurnIssuerTokenEvent</a>&gt;,
                                 specialization_id: u8,
) {
     // Destroy the actual token.
    <b>let</b> <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {issuer_address,
                                band_id,
                                amount,} = to_burn_token;
    // Can't burn non-positive amounts. Negative amounts don't make sense, and <b>while</b>
    // it's okay <b>to</b> destroy <a href="#0x1_IssuerToken">IssuerToken</a> with 0 amount, it doesn't need burn events.
    <b>assert</b>(amount &gt; 0, <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(EBURN_NON_POS));

    // Emit the corresponding burn event.
    <a href="Event.md#0x1_Event_emit_event">Event::emit_event</a>(
        event_handle,
        <a href="#0x1_IssuerToken_BurnIssuerTokenEvent">BurnIssuerTokenEvent</a> {
            specialization_id: specialization_id,
            issuer_address: issuer_address,
            band_id: band_id,
            burnt_amount: amount,
        }
    );
}
</code></pre>



</details>

<a name="0x1_IssuerToken_burn_to_issuer"></a>

## Function `burn_to_issuer`



<pre><code><b>fun</b> <a href="#0x1_IssuerToken_burn_to_issuer">burn_to_issuer</a>&lt;TokenType&gt;(sender: &signer, specialization_id: u8, issuer_address: address, band_id: u64, to_burn_amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_IssuerToken_burn_to_issuer">burn_to_issuer</a>&lt;TokenType&gt;(sender: &signer,
                              specialization_id: u8,
                              issuer_address: address,
                              band_id: u64,
                              to_burn_amount: u64,
) <b>acquires</b> <a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a> {
    <b>assert</b>(to_burn_amount &gt; 0, <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(EBURN_NON_POS));

    <b>let</b> sender_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
    <b>assert</b>(exists&lt;<a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(sender_address), <a href="Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(EMISSING_CONTAINER));
    <b>let</b> sender_tokens =
        borrow_global_mut&lt;<a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(sender_address);

    <b>let</b> (found, target_index) =
        <a href="#0x1_IssuerToken_find_issuer_token">find_issuer_token</a>&lt;TokenType&gt;(&sender_tokens.issuer_tokens,
                                     issuer_address,
                                     band_id);
    <b>assert</b>(found, <a href="Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(EISSUER_TOKEN_NOT_FOUND));
    <b>let</b> issuer_token = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> sender_tokens.issuer_tokens, target_index);
    <b>assert</b>(issuer_token.amount &gt;= to_burn_amount, <a href="Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(EBURN_EXCEEDS_LIMITS));

    // Split the issuer_token, burn the specified amount and emit corresponding event.
    <a href="#0x1_IssuerToken_burn_issuer_token">burn_issuer_token</a>&lt;TokenType&gt;(<a href="#0x1_IssuerToken_split_issuer_token">split_issuer_token</a>&lt;TokenType&gt;(issuer_token,
                                                               to_burn_amount),
                                 &<b>mut</b> sender_tokens.burn_events,
                                 specialization_id);

    // Clear the <a href="#0x1_IssuerToken">IssuerToken</a> from Container <b>if</b> the amount is 0.
    // Note: we could make this a private utility function <b>if</b> useful elsewhere.
    <b>if</b> (issuer_token.amount == 0){
        <b>let</b> <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {issuer_address: _,
                                    band_id: _,
                                    amount: _ } =
            <a href="Vector.md#0x1_Vector_swap_remove">Vector::swap_remove</a>(&<b>mut</b> sender_tokens.issuer_tokens, target_index);
    };
}
</code></pre>



</details>

<a name="0x1_IssuerToken_burn_all_to_issuer"></a>

## Function `burn_all_to_issuer`



<pre><code><b>fun</b> <a href="#0x1_IssuerToken_burn_all_to_issuer">burn_all_to_issuer</a>&lt;TokenType&gt;(sender: &signer, specialization_id: u8, issuer_address: address, band_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_IssuerToken_burn_all_to_issuer">burn_all_to_issuer</a>&lt;TokenType&gt;(sender: &signer,
                                  specialization_id: u8,
                                  issuer_address: address,
                                  band_id: u64,
) <b>acquires</b> <a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a> {
    <b>let</b> total_amount = <a href="#0x1_IssuerToken_issuer_token_balance">issuer_token_balance</a>&lt;TokenType&gt;(sender, issuer_address, band_id);

    // burn_to_issuer will check that total_amount &gt; 0.
    <a href="#0x1_IssuerToken_burn_to_issuer">burn_to_issuer</a>&lt;TokenType&gt;(sender,
                              specialization_id,
                              issuer_address,
                              band_id,
                              total_amount);
}
</code></pre>



</details>

<a name="0x1_IssuerToken_burn_all_issuer_default_tokens"></a>

## Function `burn_all_issuer_default_tokens`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_burn_all_issuer_default_tokens">burn_all_issuer_default_tokens</a>(sender: &signer, issuer_address: address, band_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_burn_all_issuer_default_tokens">burn_all_issuer_default_tokens</a>(sender: &signer,
                                          issuer_address: address,
                                          band_id: u64,
) <b>acquires</b> <a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a> {
    <a href="#0x1_IssuerToken_burn_all_to_issuer">burn_all_to_issuer</a>&lt;<a href="#0x1_IssuerToken_DefaultToken">DefaultToken</a>&gt;(sender, 0, issuer_address, band_id);
}
</code></pre>



</details>

<a name="0x1_IssuerToken_burn_issuer_default_tokens"></a>

## Function `burn_issuer_default_tokens`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_burn_issuer_default_tokens">burn_issuer_default_tokens</a>(sender: &signer, issuer_address: address, band_id: u64, to_burn_amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_burn_issuer_default_tokens">burn_issuer_default_tokens</a>(sender: &signer,
                                      issuer_address: address,
                                      band_id: u64,
                                      to_burn_amount: u64,
) <b>acquires</b> <a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a> {
    <a href="#0x1_IssuerToken_burn_to_issuer">burn_to_issuer</a>&lt;<a href="#0x1_IssuerToken_DefaultToken">DefaultToken</a>&gt;(sender, 0, issuer_address, band_id, to_burn_amount);
}
</code></pre>



</details>
