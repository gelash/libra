
<a name="0x1_TokenIssueCapability"></a>

# Module `0x1::TokenIssueCapability`

### Table of Contents

-  [Resource `TokenIssueCapability`](#0x1_TokenIssueCapability_TokenIssueCapability)
-  [Const `EWRONG_ISSUER_ADDRESS`](#0x1_TokenIssueCapability_EWRONG_ISSUER_ADDRESS)
-  [Const `EWRONG_SPECIALIZATION_ID`](#0x1_TokenIssueCapability_EWRONG_SPECIALIZATION_ID)
-  [Function `capability`](#0x1_TokenIssueCapability_capability)
-  [Function `assert_issuer_address`](#0x1_TokenIssueCapability_assert_issuer_address)
-  [Function `assert_specialization_id`](#0x1_TokenIssueCapability_assert_specialization_id)



<a name="0x1_TokenIssueCapability_TokenIssueCapability"></a>

## Resource `TokenIssueCapability`

Allows minting IssuerToken<TokenType>, with issuer address, and TokenType
specialization such that worm_specialization_id<TokenType> on issuer's
account is set to the specialization id (i.e. only allows minting one
specialization of the IssuerToken).


<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_TokenIssueCapability">TokenIssueCapability</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>issuer_address: address</code>
</dt>
<dd>

</dd>
<dt>

<code>specialization_id: u8</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_TokenIssueCapability_EWRONG_ISSUER_ADDRESS"></a>

## Const `EWRONG_ISSUER_ADDRESS`

Trying to use capability with a wrong issuer address.


<pre><code><b>const</b> EWRONG_ISSUER_ADDRESS: u64 = 0;
</code></pre>



<a name="0x1_TokenIssueCapability_EWRONG_SPECIALIZATION_ID"></a>

## Const `EWRONG_SPECIALIZATION_ID`

Trying to use capability with a wrong specialization id of IssuerToken.


<pre><code><b>const</b> EWRONG_SPECIALIZATION_ID: u64 = 1;
</code></pre>



<a name="0x1_TokenIssueCapability_capability"></a>

## Function `capability`

Need to be extremely careful when creating capabilities, i.e. should
only call it from known interfaces that provide access control, and
not leak the capability besides whatever specific purpose (e.g.
minting MoneyOrderToken when AssetHolder<IssuerToken<MoneyOrderToken>>>
is available).


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenIssueCapability_capability">capability</a>(issuer: &signer, specialization_id: u8): <a href="#0x1_TokenIssueCapability_TokenIssueCapability">TokenIssueCapability::TokenIssueCapability</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenIssueCapability_capability">capability</a>(issuer: &signer,
                      specialization_id: u8,
): <a href="#0x1_TokenIssueCapability">TokenIssueCapability</a> {
    <a href="#0x1_TokenIssueCapability">TokenIssueCapability</a> {
        issuer_address: <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer),
        specialization_id: specialization_id,
    }
}
</code></pre>



</details>

<a name="0x1_TokenIssueCapability_assert_issuer_address"></a>

## Function `assert_issuer_address`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenIssueCapability_assert_issuer_address">assert_issuer_address</a>(cap: &<a href="#0x1_TokenIssueCapability_TokenIssueCapability">TokenIssueCapability::TokenIssueCapability</a>, issuer_address: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenIssueCapability_assert_issuer_address">assert_issuer_address</a>(cap: &<a href="#0x1_TokenIssueCapability">TokenIssueCapability</a>,
                                 issuer_address: address) {
    <b>assert</b>(cap.issuer_address == issuer_address,
           <a href="Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(EWRONG_ISSUER_ADDRESS));
}
</code></pre>



</details>

<a name="0x1_TokenIssueCapability_assert_specialization_id"></a>

## Function `assert_specialization_id`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenIssueCapability_assert_specialization_id">assert_specialization_id</a>(cap: &<a href="#0x1_TokenIssueCapability_TokenIssueCapability">TokenIssueCapability::TokenIssueCapability</a>, specialization_id: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_TokenIssueCapability_assert_specialization_id">assert_specialization_id</a>(cap: &<a href="#0x1_TokenIssueCapability">TokenIssueCapability</a>,
                                    specialization_id: u8) {
    <b>assert</b>(cap.specialization_id == specialization_id,
           <a href="Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(EWRONG_SPECIALIZATION_ID));
}
</code></pre>



</details>
