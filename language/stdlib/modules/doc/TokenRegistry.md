
<a name="0x1_TokenRegistry"></a>

# Module `0x1::TokenRegistry`

### Table of Contents

-  [Resource `IdCounter`](#0x1_TokenRegistry_IdCounter)
-  [Resource `Registered`](#0x1_TokenRegistry_Registered)
-  [Resource `TokenRegistryWithMintCapability`](#0x1_TokenRegistry_TokenRegistryWithMintCapability)
-  [Function `initialize`](#0x1_TokenRegistry_initialize)
-  [Function `get_fresh_id`](#0x1_TokenRegistry_get_fresh_id)
-  [Function `register`](#0x1_TokenRegistry_register)



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

<a name="0x1_TokenRegistry_Registered"></a>

## Resource `Registered`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_TokenRegistry_Registered">Registered</a>&lt;CoinType&gt;
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

<code>metadata: u64</code>
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
    // make sure this function is only called once
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
    // add relevant asserts
    <b>let</b> addr = <a href="CoreAddresses.md#0x1_CoreAddresses_TOKEN_REGISTRY_COUNTER_ADDRESS">CoreAddresses::TOKEN_REGISTRY_COUNTER_ADDRESS</a>();
    <b>let</b> id = borrow_global_mut&lt;<a href="#0x1_TokenRegistry_IdCounter">IdCounter</a>&gt;(addr);
    id.count = id.count + 1;
    id.count
}
</code></pre>



</details>

<a name="0x1_TokenRegistry_register"></a>

## Function `register`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenRegistry_register">register</a>&lt;CoinType&gt;(maker_account: &signer, _t: &CoinType, metadata: u64): <a href="#0x1_TokenRegistry_TokenRegistryWithMintCapability">TokenRegistry::TokenRegistryWithMintCapability</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenRegistry_register">register</a>&lt;CoinType&gt;(maker_account: &signer,
                            _t: &CoinType,
                            metadata: u64,
): <a href="#0x1_TokenRegistry_TokenRegistryWithMintCapability">TokenRegistryWithMintCapability</a>&lt;CoinType&gt; <b>acquires</b> <a href="#0x1_TokenRegistry_IdCounter">IdCounter</a> {
    // increments unique counter under <b>global</b> registry address
    <b>let</b> unique_id = <a href="#0x1_TokenRegistry_get_fresh_id">get_fresh_id</a>();
    move_to&lt;<a href="#0x1_TokenRegistry_Registered">Registered</a>&lt;CoinType&gt;&gt;(
        maker_account,
        <a href="#0x1_TokenRegistry_Registered">Registered</a> { id: unique_id, metadata }
    );
    <b>let</b> address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(maker_account);
    <a href="#0x1_TokenRegistry_TokenRegistryWithMintCapability">TokenRegistryWithMintCapability</a>&lt;CoinType&gt;{maker_account: address}
}
</code></pre>



</details>
