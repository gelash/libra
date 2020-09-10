
<a name="0x1_IssuerToken"></a>

# Module `0x1::IssuerToken`

### Table of Contents

-  [Struct `DefaultToken`](#0x1_IssuerToken_DefaultToken)
-  [Struct `MoneyOrderToken`](#0x1_IssuerToken_MoneyOrderToken)
-  [Resource `IssuerToken`](#0x1_IssuerToken_IssuerToken)
-  [Resource `IssuerTokens`](#0x1_IssuerToken_IssuerTokens)
-  [Function `publish_issuer_tokens`](#0x1_IssuerToken_publish_issuer_tokens)
-  [Function `initialize`](#0x1_IssuerToken_initialize)
-  [Function `find_issuer_token`](#0x1_IssuerToken_find_issuer_token)
-  [Function `create_issuer_token`](#0x1_IssuerToken_create_issuer_token)
-  [Function `mint_issuer_token`](#0x1_IssuerToken_mint_issuer_token)
-  [Function `merge_issuer_token`](#0x1_IssuerToken_merge_issuer_token)
-  [Function `split_issuer_token`](#0x1_IssuerToken_split_issuer_token)
-  [Function `issuer_token_balance`](#0x1_IssuerToken_issuer_token_balance)
-  [Function `deposit_issuer_token`](#0x1_IssuerToken_deposit_issuer_token)



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

<a name="0x1_IssuerToken_IssuerToken"></a>

## Resource `IssuerToken`

The main IssuerToken wrapper resource. Shouldn't be stored on accounts
directly, but rather be wrapped inside IssuerTokens for holding (tokens
issued by other accounts) and BalanceHolder for distributing (tokens
issued by the holding account). Once distributed, issuer tokens should
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
 the issuer, is the only entity that can authorize issuing these
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

<a name="0x1_IssuerToken_IssuerTokens"></a>

## Resource `IssuerTokens`

Container for holding redeemed issuer tokens on accounts (i.e.
on accounts other than the issuer).


<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_IssuerToken_IssuerTokens">IssuerTokens</a>&lt;IssuerTokenType&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>issuer_tokens: vector&lt;IssuerTokenType&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_IssuerToken_publish_issuer_tokens"></a>

## Function `publish_issuer_tokens`

Publishes the IssuerTokens struct on sender's account, allowing it
to hold tokens of IssuerTokenType issued by other accounts.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_publish_issuer_tokens">publish_issuer_tokens</a>&lt;IssuerTokenType&gt;(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_publish_issuer_tokens">publish_issuer_tokens</a>&lt;IssuerTokenType&gt;(sender: &signer) {
    <b>let</b> sender_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);

    <b>if</b> (!exists&lt;<a href="#0x1_IssuerToken_IssuerTokens">IssuerTokens</a>&lt;IssuerTokenType&gt;&gt;(sender_address)) {
        move_to(sender, <a href="#0x1_IssuerToken_IssuerTokens">IssuerTokens</a>&lt;IssuerTokenType&gt; {
            issuer_tokens: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
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

    <b>assert</b>(issuer_token_a.issuer_address == issuer_address, 8006);
    <b>assert</b>(issuer_token_a.band_id == band_id, 8006);

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
    <b>assert</b>(issuer_token.amount &gt;= amount, 8004);

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

<a name="0x1_IssuerToken_issuer_token_balance"></a>

## Function `issuer_token_balance`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_issuer_token_balance">issuer_token_balance</a>&lt;TokenType&gt;(sender: &signer, issuer_address: address, band_id: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_issuer_token_balance">issuer_token_balance</a>&lt;TokenType&gt;(sender: &signer,
                                           issuer_address: address,
                                           band_id: u64,
): u64 <b>acquires</b> <a href="#0x1_IssuerToken_IssuerTokens">IssuerTokens</a> {
    <b>let</b> sender_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
    <b>if</b> (!exists&lt;<a href="#0x1_IssuerToken_IssuerTokens">IssuerTokens</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(sender_address)) {
        <b>return</b> 0
    };
    <b>let</b> sender_tokens =
        borrow_global&lt;<a href="#0x1_IssuerToken_IssuerTokens">IssuerTokens</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(sender_address);

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

Deposits the issuer token in the IssuerTokens structure on receiver's account.
It's asserted that receiver != issuer, and IssuerTokens<TokenType> is created
if not already published on the receiver's account.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_deposit_issuer_token">deposit_issuer_token</a>&lt;TokenType&gt;(receiver: &signer, issuer_token: <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_deposit_issuer_token">deposit_issuer_token</a>&lt;TokenType&gt;(receiver: &signer,
                                           issuer_token: <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;
) <b>acquires</b> <a href="#0x1_IssuerToken_IssuerTokens">IssuerTokens</a> {
    <b>let</b> receiver_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(receiver);
    <b>assert</b>(issuer_token.issuer_address != receiver_address, 8005);

    <b>if</b> (!exists&lt;<a href="#0x1_IssuerToken_IssuerTokens">IssuerTokens</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(receiver_address)) {
        <a href="#0x1_IssuerToken_publish_issuer_tokens">publish_issuer_tokens</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;(receiver);
    };
    <b>let</b> receiver_tokens =
        borrow_global_mut&lt;<a href="#0x1_IssuerToken_IssuerTokens">IssuerTokens</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(receiver_address);

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
