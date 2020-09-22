
<a name="0x1_IssuerToken"></a>

# Module `0x1::IssuerToken`

### Table of Contents

-  [Struct `RedeemedIssuerTokenEvent`](#0x1_IssuerToken_RedeemedIssuerTokenEvent)
-  [Resource `IssuerToken`](#0x1_IssuerToken_IssuerToken)
-  [Resource `IssuerTokenContainer`](#0x1_IssuerToken_IssuerTokenContainer)
-  [Resource `WormSpecializationId`](#0x1_IssuerToken_WormSpecializationId)
-  [Resource `IssuerTokenSpecializationIds`](#0x1_IssuerToken_IssuerTokenSpecializationIds)
-  [Const `EDEPOSIT_EXCEEDS_LIMITS`](#0x1_IssuerToken_EDEPOSIT_EXCEEDS_LIMITS)
-  [Const `ESELF_DEPOSIT`](#0x1_IssuerToken_ESELF_DEPOSIT)
-  [Const `EILLEGAL_MERGE`](#0x1_IssuerToken_EILLEGAL_MERGE)
-  [Const `EREDEEM_NON_POSITIVE`](#0x1_IssuerToken_EREDEEM_NON_POSITIVE)
-  [Const `EMISSING_CONTAINER`](#0x1_IssuerToken_EMISSING_CONTAINER)
-  [Const `EISSUER_TOKEN_NOT_FOUND`](#0x1_IssuerToken_EISSUER_TOKEN_NOT_FOUND)
-  [Const `EREDEEM_EXCEEDS_LIMITS`](#0x1_IssuerToken_EREDEEM_EXCEEDS_LIMITS)
-  [Const `ESPECIALIZATION_ID_NEGATIVE`](#0x1_IssuerToken_ESPECIALIZATION_ID_NEGATIVE)
-  [Const `ESPECIALIZATION_ID_NON_UNIQUE`](#0x1_IssuerToken_ESPECIALIZATION_ID_NON_UNIQUE)
-  [Const `ESPECIALIZATION_ID_CONFLICT`](#0x1_IssuerToken_ESPECIALIZATION_ID_CONFLICT)
-  [Const `ESPECIALIZATION_ID_NOT_FOUND`](#0x1_IssuerToken_ESPECIALIZATION_ID_NOT_FOUND)
-  [Function `worm_specialization_id`](#0x1_IssuerToken_worm_specialization_id)
-  [Function `assert_unique_specialization_id`](#0x1_IssuerToken_assert_unique_specialization_id)
-  [Function `register_token_specialization`](#0x1_IssuerToken_register_token_specialization)
-  [Function `publish_issuer_token_container`](#0x1_IssuerToken_publish_issuer_token_container)
-  [Function `find_issuer_token`](#0x1_IssuerToken_find_issuer_token)
-  [Function `mint_issuer_token`](#0x1_IssuerToken_mint_issuer_token)
-  [Function `mint_issuer_token_with_capability`](#0x1_IssuerToken_mint_issuer_token_with_capability)
-  [Function `merge_issuer_token`](#0x1_IssuerToken_merge_issuer_token)
-  [Function `split_issuer_token`](#0x1_IssuerToken_split_issuer_token)
-  [Function `value`](#0x1_IssuerToken_value)
-  [Function `issuer_token_balance`](#0x1_IssuerToken_issuer_token_balance)
-  [Function `deposit_issuer_token`](#0x1_IssuerToken_deposit_issuer_token)
-  [Function `redeem_issuer_token`](#0x1_IssuerToken_redeem_issuer_token)
-  [Function `redeem`](#0x1_IssuerToken_redeem)
-  [Function `redeem_all`](#0x1_IssuerToken_redeem_all)



<a name="0x1_IssuerToken_RedeemedIssuerTokenEvent"></a>

## Struct `RedeemedIssuerTokenEvent`

RedeemedIssuerTokenEvent, when emitted, serves as a unique certificate
that the sender burnt a specified amount of the specified issuer token
type. Once an amount is burnt, it's subtracted from the available amount.


<pre><code><b>struct</b> <a href="#0x1_IssuerToken_RedeemedIssuerTokenEvent">RedeemedIssuerTokenEvent</a>
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

<code>redeemed_amount: u64</code>
</dt>
<dd>
 Amount of the IssuerTokens that were redeemed.
</dd>
</dl>


</details>

<a name="0x1_IssuerToken_IssuerToken"></a>

## Resource `IssuerToken`

The main IssuerToken wrapper resource. Shouldn't be stored on accounts
directly, but rather be wrapped inside IssuerTokenContainer for tokens
issued by other accounts, and BalanceHolder for distributing tokens
issued by the holding account. Once distributed, issuer tokens should
never go back to issuer, they can only be redeemed (i.e. burnt & exhanged
for the Redeem event that certifies the burn/redemption).
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

<code>redemption_events: <a href="Event.md#0x1_Event_EventHandle">Event::EventHandle</a>&lt;<a href="#0x1_IssuerToken_RedeemedIssuerTokenEvent">IssuerToken::RedeemedIssuerTokenEvent</a>&gt;</code>
</dt>
<dd>
 Event stream for redeeming IssuerTokens (emits these events).
</dd>
</dl>


</details>

<a name="0x1_IssuerToken_WormSpecializationId"></a>

## Resource `WormSpecializationId`

Write-once read-many resource that when published on issuer's account,
uniquely identifies a given TokenType for the issuer. Redemption events
identify TokenType using the ID based on this structure, which is why
it's required that (1) the worm_specialization_id<TokenType> exists
on issuer's account; (2) all mapped ID's are unique; and (3) once
published, the ID's are immutable.


<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_IssuerToken_WormSpecializationId">WormSpecializationId</a>&lt;TokenType&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>specialization_id: u8</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_IssuerToken_IssuerTokenSpecializationIds"></a>

## Resource `IssuerTokenSpecializationIds`

Used to ensure uniqueness of WormSpecializationId's.


<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_IssuerToken_IssuerTokenSpecializationIds">IssuerTokenSpecializationIds</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>all_ids: vector&lt;u8&gt;</code>
</dt>
<dd>

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



<a name="0x1_IssuerToken_EREDEEM_NON_POSITIVE"></a>

## Const `EREDEEM_NON_POSITIVE`

A redemption was attempted with non-positive amount


<pre><code><b>const</b> EREDEEM_NON_POSITIVE: u64 = 3;
</code></pre>



<a name="0x1_IssuerToken_EMISSING_CONTAINER"></a>

## Const `EMISSING_CONTAINER`

A redemption of IssuerToken<TokenType>> was attempted, but the matching
IssuerTokenContainer didn't exist on the account.


<pre><code><b>const</b> EMISSING_CONTAINER: u64 = 4;
</code></pre>



<a name="0x1_IssuerToken_EISSUER_TOKEN_NOT_FOUND"></a>

## Const `EISSUER_TOKEN_NOT_FOUND`

Could not find issuer token based on address


<pre><code><b>const</b> EISSUER_TOKEN_NOT_FOUND: u64 = 5;
</code></pre>



<a name="0x1_IssuerToken_EREDEEM_EXCEEDS_LIMITS"></a>

## Const `EREDEEM_EXCEEDS_LIMITS`

Trying to redeem amount surpassing the account's limits


<pre><code><b>const</b> EREDEEM_EXCEEDS_LIMITS: u64 = 6;
</code></pre>



<a name="0x1_IssuerToken_ESPECIALIZATION_ID_NEGATIVE"></a>

## Const `ESPECIALIZATION_ID_NEGATIVE`

Registering a negative specialization id for a TokenType.


<pre><code><b>const</b> ESPECIALIZATION_ID_NEGATIVE: u64 = 7;
</code></pre>



<a name="0x1_IssuerToken_ESPECIALIZATION_ID_NON_UNIQUE"></a>

## Const `ESPECIALIZATION_ID_NON_UNIQUE`

Registering a non-unique specialization id for a TokenType.


<pre><code><b>const</b> ESPECIALIZATION_ID_NON_UNIQUE: u64 = 8;
</code></pre>



<a name="0x1_IssuerToken_ESPECIALIZATION_ID_CONFLICT"></a>

## Const `ESPECIALIZATION_ID_CONFLICT`

Registering worm specialization id for TokenType with conflicting IDs.


<pre><code><b>const</b> ESPECIALIZATION_ID_CONFLICT: u64 = 9;
</code></pre>



<a name="0x1_IssuerToken_ESPECIALIZATION_ID_NOT_FOUND"></a>

## Const `ESPECIALIZATION_ID_NOT_FOUND`

Using TokenType that doesn't have a registered specialization id.


<pre><code><b>const</b> ESPECIALIZATION_ID_NOT_FOUND: u64 = 10;
</code></pre>



<a name="0x1_IssuerToken_worm_specialization_id"></a>

## Function `worm_specialization_id`

Find the specialization Id for a given TokenType specialization for
a given issuer address. Returns (false, 0) if IssuerToken<TokenType>
not yet in use by the issuer (account w. issuer_address).


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_worm_specialization_id">worm_specialization_id</a>&lt;TokenType&gt;(issuer_address: address): (bool, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_worm_specialization_id">worm_specialization_id</a>&lt;TokenType&gt;(issuer_address: address,
): (bool, u8) <b>acquires</b> <a href="#0x1_IssuerToken_WormSpecializationId">WormSpecializationId</a> {
    <b>if</b> (!exists&lt;<a href="#0x1_IssuerToken_WormSpecializationId">WormSpecializationId</a>&lt;TokenType&gt;&gt;(issuer_address)) {
        <b>return</b> (<b>false</b>, 0)
    };

    <b>let</b> worm_id =
        borrow_global&lt;<a href="#0x1_IssuerToken_WormSpecializationId">WormSpecializationId</a>&lt;TokenType&gt;&gt;(issuer_address);
    (<b>true</b>, worm_id.specialization_id)
}
</code></pre>



</details>

<a name="0x1_IssuerToken_assert_unique_specialization_id"></a>

## Function `assert_unique_specialization_id`



<pre><code><b>fun</b> <a href="#0x1_IssuerToken_assert_unique_specialization_id">assert_unique_specialization_id</a>&lt;TokenType&gt;(account_address: address, specialization_id: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_IssuerToken_assert_unique_specialization_id">assert_unique_specialization_id</a>&lt;TokenType&gt;(account_address: address,
                                               specialization_id: u8,
) <b>acquires</b> <a href="#0x1_IssuerToken_WormSpecializationId">WormSpecializationId</a> {
    <b>let</b> (found, worm_id) = <a href="#0x1_IssuerToken_worm_specialization_id">worm_specialization_id</a>&lt;TokenType&gt;(account_address);
    <b>assert</b>(!found || worm_id == specialization_id,
           <a href="Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(ESPECIALIZATION_ID_CONFLICT));
}
</code></pre>



</details>

<a name="0x1_IssuerToken_register_token_specialization"></a>

## Function `register_token_specialization`

Before using IssuerToken<TokenType>, every issuer account must register
the TokenType by calling register_token_specialization<TokenType> providing
a unique specialization ID (which cannot be reset later). This is used to
identify the type of issuer token in events, etc.

For TokenTypes that are registered with a unique ID on the Libra root
account during genesis, the same ID must be used (e.g. DefaultToken must
have specialization id 0 when being registered by any account).


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_register_token_specialization">register_token_specialization</a>&lt;TokenType&gt;(issuer: &signer, specialization_id: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_register_token_specialization">register_token_specialization</a>&lt;TokenType&gt;(issuer: &signer,
                                                    specialization_id: u8,
) <b>acquires</b> <a href="#0x1_IssuerToken_IssuerTokenSpecializationIds">IssuerTokenSpecializationIds</a>, <a href="#0x1_IssuerToken_WormSpecializationId">WormSpecializationId</a> {
    <b>assert</b>(specialization_id &gt;= 0,
           <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(ESPECIALIZATION_ID_NEGATIVE));

    <b>let</b> issuer_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer);
    <b>if</b> (!exists&lt;<a href="#0x1_IssuerToken_IssuerTokenSpecializationIds">IssuerTokenSpecializationIds</a>&gt;(issuer_address)) {
        move_to(issuer, <a href="#0x1_IssuerToken_IssuerTokenSpecializationIds">IssuerTokenSpecializationIds</a> {
            all_ids: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
        });
    };

    // Ensure specialization id not previously set <b>to</b> something <b>else</b>
    // on issuer's or Libra_root's account.
    <a href="#0x1_IssuerToken_assert_unique_specialization_id">assert_unique_specialization_id</a>&lt;TokenType&gt;(issuer_address,
                                               specialization_id);
    <a href="#0x1_IssuerToken_assert_unique_specialization_id">assert_unique_specialization_id</a>&lt;TokenType&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_LIBRA_ROOT_ADDRESS">CoreAddresses::LIBRA_ROOT_ADDRESS</a>(),
                                               specialization_id);

    <b>if</b> (!exists&lt;<a href="#0x1_IssuerToken_WormSpecializationId">WormSpecializationId</a>&lt;TokenType&gt;&gt;(issuer_address)) {
        <b>let</b> ids = borrow_global_mut&lt;<a href="#0x1_IssuerToken_IssuerTokenSpecializationIds">IssuerTokenSpecializationIds</a>&gt;(issuer_address);
        // Ensure specialization_id is unique.
        <b>assert</b>(!<a href="Vector.md#0x1_Vector_contains">Vector::contains</a>(&ids.all_ids, &specialization_id),
               <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(ESPECIALIZATION_ID_NON_UNIQUE));

        // Set specialization id and record in all ids.
        move_to(issuer, <a href="#0x1_IssuerToken_WormSpecializationId">WormSpecializationId</a>&lt;TokenType&gt; {
            specialization_id: specialization_id,
        });
        <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> ids.all_ids, specialization_id);
    }
}
</code></pre>



</details>

<a name="0x1_IssuerToken_publish_issuer_token_container"></a>

## Function `publish_issuer_token_container`

Publishes the IssuerTokenContainer struct on sender's account, allowing it
to hold tokens of IssuerTokenType issued by other accounts.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_publish_issuer_token_container">publish_issuer_token_container</a>&lt;TokenType&gt;(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_publish_issuer_token_container">publish_issuer_token_container</a>&lt;TokenType&gt;(sender: &signer) {
    // TODO: when available, <b>use</b> aliasing for <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;
    <b>let</b> sender_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);

    <b>if</b> (!exists&lt;<a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(sender_address)) {
        move_to(sender, <a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt; {
            issuer_tokens: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
            redemption_events: <a href="Event.md#0x1_Event_new_event_handle">Event::new_event_handle</a>&lt;<a href="#0x1_IssuerToken_RedeemedIssuerTokenEvent">RedeemedIssuerTokenEvent</a>&gt;(
                sender)
        });
    };
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

<a name="0x1_IssuerToken_mint_issuer_token"></a>

## Function `mint_issuer_token`

Sender can mint arbitrary amounts of its own IssuerToken
(with its own address).


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_mint_issuer_token">mint_issuer_token</a>&lt;TokenType&gt;(issuer: &signer, band_id: u64, amount: u64): <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_mint_issuer_token">mint_issuer_token</a>&lt;TokenType&gt;(issuer: &signer,
                                        band_id: u64,
                                        amount: u64,
): <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {
    <b>let</b> issuer_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer);

    <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {
        issuer_address: issuer_address,
        band_id: band_id,
        amount: amount
    }
}
</code></pre>



</details>

<a name="0x1_IssuerToken_mint_issuer_token_with_capability"></a>

## Function `mint_issuer_token_with_capability`

Sender can mint arbitrary amounts of its own IssuerToken
(with its own address).


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_mint_issuer_token_with_capability">mint_issuer_token_with_capability</a>&lt;TokenType&gt;(capability: &<a href="TokenIssueCapability.md#0x1_TokenIssueCapability_TokenIssueCapability">TokenIssueCapability::TokenIssueCapability</a>, issuer_address: address, band_id: u64, amount: u64): <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_mint_issuer_token_with_capability">mint_issuer_token_with_capability</a>&lt;TokenType&gt;(
    capability: &<a href="TokenIssueCapability.md#0x1_TokenIssueCapability">TokenIssueCapability</a>,
    issuer_address: address,
    band_id: u64,
    amount: u64,
): <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; <b>acquires</b> <a href="#0x1_IssuerToken_WormSpecializationId">WormSpecializationId</a> {
    // Make sure capability matches the issuer address and the
    // specialization id corresponding <b>to</b> the TokenType.
    <a href="TokenIssueCapability.md#0x1_TokenIssueCapability_assert_issuer_address">TokenIssueCapability::assert_issuer_address</a>(capability,
                                                issuer_address);
    <b>let</b> (found, worm_id) =
        <a href="#0x1_IssuerToken_worm_specialization_id">worm_specialization_id</a>&lt;TokenType&gt;(issuer_address);
    <b>assert</b>(found, <a href="Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(ESPECIALIZATION_ID_NOT_FOUND));
    <a href="TokenIssueCapability.md#0x1_TokenIssueCapability_assert_specialization_id">TokenIssueCapability::assert_specialization_id</a>(capability,
                                                   worm_id);

    <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {
        issuer_address: issuer_address,
        band_id: band_id,
        amount: amount
    }
}
</code></pre>



</details>

<a name="0x1_IssuerToken_merge_issuer_token"></a>

## Function `merge_issuer_token`

Merge two IssuerTokens, i.e. combine the amounts of two tokens
into the first one (the second token gets destroyed).


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

    <b>assert</b>(issuer_token_a.issuer_address == issuer_address,
           <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(EILLEGAL_MERGE));
    <b>assert</b>(issuer_token_a.band_id == band_id,
           <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(EILLEGAL_MERGE));

    <b>let</b> token_amount = &<b>mut</b> issuer_token_a.amount;
    *token_amount = *token_amount + amount;
}
</code></pre>



</details>

<a name="0x1_IssuerToken_split_issuer_token"></a>

## Function `split_issuer_token`

Extract a token of specified amount out of a given token (whose amount
is decreased accordingly).


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_split_issuer_token">split_issuer_token</a>&lt;TokenType&gt;(issuer_token: &<b>mut</b> <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;, amount: u64): <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_split_issuer_token">split_issuer_token</a>&lt;TokenType&gt;(
    issuer_token: &<b>mut</b> <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;,
    amount: u64,
): <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {
    <b>assert</b>(issuer_token.amount &gt;= amount,
           <a href="Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(EDEPOSIT_EXCEEDS_LIMITS));
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

    // If the container doesn't exist, will publish it, allowing <b>to</b> hold IssuerTokens.
    <a href="#0x1_IssuerToken_publish_issuer_token_container">publish_issuer_token_container</a>&lt;TokenType&gt;(receiver);
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
                          <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {
                              issuer_address: issuer_token.issuer_address,
                              band_id: issuer_token.band_id,
                              amount: 0
                          });
    };

    // Actually increment the issuer token amount.
    <a href="#0x1_IssuerToken_merge_issuer_token">merge_issuer_token</a>(<a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> receiver_tokens.issuer_tokens,
                                          target_index),
                       issuer_token);
}
</code></pre>



</details>

<a name="0x1_IssuerToken_redeem_issuer_token"></a>

## Function `redeem_issuer_token`



<pre><code><b>fun</b> <a href="#0x1_IssuerToken_redeem_issuer_token">redeem_issuer_token</a>&lt;TokenType&gt;(to_redeem_token: <a href="#0x1_IssuerToken_IssuerToken">IssuerToken::IssuerToken</a>&lt;TokenType&gt;, event_handle: &<b>mut</b> <a href="Event.md#0x1_Event_EventHandle">Event::EventHandle</a>&lt;<a href="#0x1_IssuerToken_RedeemedIssuerTokenEvent">IssuerToken::RedeemedIssuerTokenEvent</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_IssuerToken_redeem_issuer_token">redeem_issuer_token</a>&lt;TokenType&gt;(to_redeem_token: <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;,
                                   event_handle: &<b>mut</b> EventHandle&lt;<a href="#0x1_IssuerToken_RedeemedIssuerTokenEvent">RedeemedIssuerTokenEvent</a>&gt;,
) <b>acquires</b> <a href="#0x1_IssuerToken_WormSpecializationId">WormSpecializationId</a> {
     // Destroy the actual token.
    <b>let</b> <a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt; {issuer_address,
                                band_id,
                                amount,} = to_redeem_token;
    // Can't redeem non-positive amounts. Negative amounts don't make sense, and <b>while</b>
    // it's okay <b>to</b> destroy <a href="#0x1_IssuerToken">IssuerToken</a> with 0 amount, it doesn't need redemption events.
    <b>assert</b>(amount &gt; 0, <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(EREDEEM_NON_POSITIVE));

    <b>let</b> (found, worm_id) = <a href="#0x1_IssuerToken_worm_specialization_id">worm_specialization_id</a>&lt;TokenType&gt;(issuer_address);
    <b>assert</b>(found, <a href="Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(ESPECIALIZATION_ID_NOT_FOUND));

    // Emit the corresponding redemption event.
    <a href="Event.md#0x1_Event_emit_event">Event::emit_event</a>(
        event_handle,
        <a href="#0x1_IssuerToken_RedeemedIssuerTokenEvent">RedeemedIssuerTokenEvent</a> {
            specialization_id: worm_id,
            issuer_address: issuer_address,
            band_id: band_id,
            redeemed_amount: amount,
        }
    );
}
</code></pre>



</details>

<a name="0x1_IssuerToken_redeem"></a>

## Function `redeem`

Redeems the to_redeem_amount of IssuerToken (with a given issuer address & band_id)
from the IssuerTokenContainer on sender's account. Redemption is accomplished by
burning the specified amount (subtracting from available amount) and logging a
redemption event that serves as a certificate. Emits error if insufficient balance.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_redeem">redeem</a>&lt;TokenType&gt;(sender: &signer, issuer_address: address, band_id: u64, to_redeem_amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_IssuerToken_redeem">redeem</a>&lt;TokenType&gt;(sender: &signer,
                             issuer_address: address,
                             band_id: u64,
                             to_redeem_amount: u64,
) <b>acquires</b> <a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>, <a href="#0x1_IssuerToken_WormSpecializationId">WormSpecializationId</a> {
    <b>assert</b>(to_redeem_amount &gt; 0, <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(EREDEEM_NON_POSITIVE));

    <b>let</b> sender_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
    <b>assert</b>(exists&lt;<a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(sender_address),
           <a href="Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(EMISSING_CONTAINER));
    <b>let</b> sender_tokens =
        borrow_global_mut&lt;<a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>&lt;<a href="#0x1_IssuerToken">IssuerToken</a>&lt;TokenType&gt;&gt;&gt;(sender_address);

    <b>let</b> (found, target_index) =
        <a href="#0x1_IssuerToken_find_issuer_token">find_issuer_token</a>&lt;TokenType&gt;(&sender_tokens.issuer_tokens,
                                     issuer_address,
                                     band_id);
    <b>assert</b>(found, <a href="Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(EISSUER_TOKEN_NOT_FOUND));
    <b>let</b> issuer_token = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> sender_tokens.issuer_tokens, target_index);
    <b>assert</b>(issuer_token.amount &gt;= to_redeem_amount,
           <a href="Errors.md#0x1_Errors_limit_exceeded">Errors::limit_exceeded</a>(EREDEEM_EXCEEDS_LIMITS));

    // Split the issuer_token, redeem the specified amount and emit corresponding event.
    <a href="#0x1_IssuerToken_redeem_issuer_token">redeem_issuer_token</a>&lt;TokenType&gt;(<a href="#0x1_IssuerToken_split_issuer_token">split_issuer_token</a>&lt;TokenType&gt;(issuer_token,
                                                                 to_redeem_amount),
                                   &<b>mut</b> sender_tokens.redemption_events);

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

<a name="0x1_IssuerToken_redeem_all"></a>

## Function `redeem_all`

Redeems all available amount of IssuerToken (with a given issuer address & band_id)
from the IssuerTokenContainer on sender's account. Available balance has to be > 0.


<pre><code><b>fun</b> <a href="#0x1_IssuerToken_redeem_all">redeem_all</a>&lt;TokenType&gt;(sender: &signer, issuer_address: address, band_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_IssuerToken_redeem_all">redeem_all</a>&lt;TokenType&gt;(sender: &signer,
                          issuer_address: address,
                          band_id: u64,
) <b>acquires</b> <a href="#0x1_IssuerToken_IssuerTokenContainer">IssuerTokenContainer</a>, <a href="#0x1_IssuerToken_WormSpecializationId">WormSpecializationId</a> {
    <b>let</b> total_amount = <a href="#0x1_IssuerToken_issuer_token_balance">issuer_token_balance</a>&lt;TokenType&gt;(sender, issuer_address, band_id);

    // <a href="#0x1_IssuerToken_redeem">redeem</a>&lt;TokenType&gt; will check that total_amount &gt; 0.
    <a href="#0x1_IssuerToken_redeem">redeem</a>&lt;TokenType&gt;(sender,
                      issuer_address,
                      band_id,
                      total_amount);
}
</code></pre>



</details>
