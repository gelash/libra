
<a name="0x1_TokenRegistry"></a>

# Module `0x1::TokenRegistry`

### Table of Contents

-  [Resource `IdCounter`](#0x1_TokenRegistry_IdCounter)
-  [Resource `TokenMetadata`](#0x1_TokenRegistry_TokenMetadata)
-  [Resource `TokenRegistryWithMintCapability`](#0x1_TokenRegistry_TokenRegistryWithMintCapability)
-  [Resource `TokenMadeBy`](#0x1_TokenRegistry_TokenMadeBy)
-  [Const `EID_COUNTER`](#0x1_TokenRegistry_EID_COUNTER)
-  [Const `ETOKEN_REG`](#0x1_TokenRegistry_ETOKEN_REG)
-  [Function `initialize`](#0x1_TokenRegistry_initialize)
-  [Function `get_fresh_id`](#0x1_TokenRegistry_get_fresh_id)
-  [Function `register`](#0x1_TokenRegistry_register)
-  [Function `assert_is_registered_at`](#0x1_TokenRegistry_assert_is_registered_at)
-  [Function `is_transferable`](#0x1_TokenRegistry_is_transferable)



<a name="0x1_TokenRegistry_IdCounter"></a>

## Resource `IdCounter`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_TokenRegistry_IdCounter">IdCounter</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>count: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_TokenRegistry_TokenMetadata"></a>

## Resource `TokenMetadata`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_TokenRegistry_TokenMetadata">TokenMetadata</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>id: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>transferable: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_TokenRegistry_TokenRegistryWithMintCapability"></a>

## Resource `TokenRegistryWithMintCapability`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_TokenRegistry_TokenRegistryWithMintCapability">TokenRegistryWithMintCapability</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>maker_account: address</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_TokenRegistry_TokenMadeBy"></a>

## Resource `TokenMadeBy`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_TokenRegistry_TokenMadeBy">TokenMadeBy</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>maker_account: address</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_TokenRegistry_EID_COUNTER"></a>

## Const `EID_COUNTER`

A property expected of a
<code><a href="#0x1_TokenRegistry_IdCounter">IdCounter</a></code> resource didn't hold


<pre><code><b>const</b> EID_COUNTER: u64 = 1;
</code></pre>



<a name="0x1_TokenRegistry_ETOKEN_REG"></a>

## Const `ETOKEN_REG`

A property expected of a
<code><a href="#0x1_TokenRegistry_TokenMetadata">TokenMetadata</a></code> resource didn't hold


<pre><code><b>const</b> ETOKEN_REG: u64 = 2;
</code></pre>



<a name="0x1_TokenRegistry_initialize"></a>

## Function `initialize`

Initialization of the
<code><a href="#0x1_TokenRegistry">TokenRegistry</a></code> module; initializes
the counter of unique IDs


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenRegistry_initialize">initialize</a>(config_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenRegistry_initialize">initialize</a>(
    config_account: &signer,
) {
    <b>assert</b>(
        !exists&lt;<a href="#0x1_TokenRegistry_IdCounter">IdCounter</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(config_account)),
        <a href="Errors.md#0x1_Errors_already_published">Errors::already_published</a>(EID_COUNTER)
    );
    move_to(config_account, <a href="#0x1_TokenRegistry_IdCounter">IdCounter</a> {count: 0});
}
</code></pre>



</details>

<a name="0x1_TokenRegistry_get_fresh_id"></a>

## Function `get_fresh_id`



<pre><code><b>fun</b> <a href="#0x1_TokenRegistry_get_fresh_id">get_fresh_id</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_TokenRegistry_get_fresh_id">get_fresh_id</a>(): u64 <b>acquires</b> <a href="#0x1_TokenRegistry_IdCounter">IdCounter</a>{
    <b>let</b> addr = <a href="CoreAddresses.md#0x1_CoreAddresses_TOKEN_REGISTRY_COUNTER_ADDRESS">CoreAddresses::TOKEN_REGISTRY_COUNTER_ADDRESS</a>();
    <b>assert</b>(exists&lt;<a href="#0x1_TokenRegistry_IdCounter">IdCounter</a>&gt;(addr), <a href="Errors.md#0x1_Errors_not_published">Errors::not_published</a>(EID_COUNTER));
    <b>let</b> id = borrow_global_mut&lt;<a href="#0x1_TokenRegistry_IdCounter">IdCounter</a>&gt;(addr);
    id.count = id.count + 1;
    id.count
}
</code></pre>



</details>

<a name="0x1_TokenRegistry_register"></a>

## Function `register`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenRegistry_register">register</a>&lt;CoinType&gt;(maker_account: &signer, _t: &CoinType, transferable: bool): <a href="#0x1_TokenRegistry_TokenRegistryWithMintCapability">TokenRegistry::TokenRegistryWithMintCapability</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenRegistry_register">register</a>&lt;CoinType&gt;(maker_account: &signer,
                            _t: &CoinType,
                            transferable: bool,
): <a href="#0x1_TokenRegistry_TokenRegistryWithMintCapability">TokenRegistryWithMintCapability</a>&lt;CoinType&gt; <b>acquires</b> <a href="#0x1_TokenRegistry_IdCounter">IdCounter</a> {
    // add test for the line below
    <b>assert</b>(!exists&lt;<a href="#0x1_TokenRegistry_TokenMetadata">TokenMetadata</a>&lt;CoinType&gt;&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(maker_account)), <a href="Errors.md#0x1_Errors_already_published">Errors::already_published</a>(ETOKEN_REG));
    // increments unique counter under <b>global</b> registry address
    <b>let</b> unique_id = <a href="#0x1_TokenRegistry_get_fresh_id">get_fresh_id</a>();
    // print for testing, can remove later
    <a href="Debug.md#0x1_Debug_print">Debug::print</a>(&unique_id);
    move_to&lt;<a href="#0x1_TokenRegistry_TokenMetadata">TokenMetadata</a>&lt;CoinType&gt;&gt;(
        maker_account,
        <a href="#0x1_TokenRegistry_TokenMetadata">TokenMetadata</a> { id: unique_id, transferable}
    );
    <b>let</b> address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(maker_account);
    <a href="#0x1_TokenRegistry_TokenRegistryWithMintCapability">TokenRegistryWithMintCapability</a>&lt;CoinType&gt;{maker_account: address}
}
</code></pre>



</details>

<a name="0x1_TokenRegistry_assert_is_registered_at"></a>

## Function `assert_is_registered_at`

Asserts that
<code>CoinType</code> is a registered type at the given address


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenRegistry_assert_is_registered_at">assert_is_registered_at</a>&lt;CoinType&gt;(registered_at: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenRegistry_assert_is_registered_at">assert_is_registered_at</a>&lt;CoinType&gt; (registered_at: address){
    <b>assert</b>(exists&lt;<a href="#0x1_TokenRegistry_TokenMetadata">TokenMetadata</a>&lt;CoinType&gt;&gt;(registered_at), <a href="Errors.md#0x1_Errors_not_published">Errors::not_published</a>(ETOKEN_REG));
}
</code></pre>



</details>

<a name="0x1_TokenRegistry_is_transferable"></a>

## Function `is_transferable`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenRegistry_is_transferable">is_transferable</a>&lt;CoinType&gt;(registered_at: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenRegistry_is_transferable">is_transferable</a>&lt;CoinType&gt;(registered_at: address): bool <b>acquires</b> <a href="#0x1_TokenRegistry_TokenMetadata">TokenMetadata</a>{
    <a href="#0x1_TokenRegistry_assert_is_registered_at">assert_is_registered_at</a>&lt;CoinType&gt;(registered_at);
    <b>let</b> metadata = borrow_global&lt;<a href="#0x1_TokenRegistry_TokenMetadata">TokenMetadata</a>&lt;CoinType&gt;&gt;(registered_at);
    metadata.transferable
}
</code></pre>



</details>
