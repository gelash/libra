
<a name="0x1_ShardedBitVector"></a>

# Module `0x1::ShardedBitVector`

### Table of Contents

-  [Resource `BitVectorBatch`](#0x1_ShardedBitVector_BitVectorBatch)
-  [Resource `BitVectorShard`](#0x1_ShardedBitVector_BitVectorShard)
-  [Resource `BitVectorInfo`](#0x1_ShardedBitVector_BitVectorInfo)
-  [Function `empty_info`](#0x1_ShardedBitVector_empty_info)
-  [Function `empty_shard`](#0x1_ShardedBitVector_empty_shard)
-  [Function `initialize`](#0x1_ShardedBitVector_initialize)
-  [Function `register_as_shard`](#0x1_ShardedBitVector_register_as_shard)
-  [Function `lock_info`](#0x1_ShardedBitVector_lock_info)
-  [Function `time_expired`](#0x1_ShardedBitVector_time_expired)
-  [Function `div_ceil`](#0x1_ShardedBitVector_div_ceil)
-  [Function `vector_with_copies`](#0x1_ShardedBitVector_vector_with_copies)
-  [Function `issue_batch_on_shard`](#0x1_ShardedBitVector_issue_batch_on_shard)
-  [Function `issue_batch`](#0x1_ShardedBitVector_issue_batch)
-  [Function `test_and_set_bit_on_shard`](#0x1_ShardedBitVector_test_and_set_bit_on_shard)
-  [Function `test_and_set_bit`](#0x1_ShardedBitVector_test_and_set_bit)
-  [Function `clear_vector`](#0x1_ShardedBitVector_clear_vector)
-  [Function `clear_bits_if_expired`](#0x1_ShardedBitVector_clear_bits_if_expired)
-  [Function `compress_expired_batch_on_shard`](#0x1_ShardedBitVector_compress_expired_batch_on_shard)
-  [Function `compress_expired_batch`](#0x1_ShardedBitVector_compress_expired_batch)
-  [Function `compress_expired_batches`](#0x1_ShardedBitVector_compress_expired_batches)



<a name="0x1_ShardedBitVector_BitVectorBatch"></a>

## Resource `BitVectorBatch`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_ShardedBitVector_BitVectorBatch">BitVectorBatch</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>boxed_bits: vector&lt;u128&gt;</code>
</dt>
<dd>

</dd>
<dt>

<code>expiration_time: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_ShardedBitVector_BitVectorShard"></a>

## Resource `BitVectorShard`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>primary: address</code>
</dt>
<dd>

</dd>
<dt>

<code>batches: vector&lt;<a href="#0x1_ShardedBitVector_BitVectorBatch">ShardedBitVector::BitVectorBatch</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_ShardedBitVector_BitVectorInfo"></a>

## Resource `BitVectorInfo`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_ShardedBitVector_BitVectorInfo">BitVectorInfo</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>primary: address</code>
</dt>
<dd>

</dd>
<dt>

<code>locked: bool</code>
</dt>
<dd>

</dd>
<dt>

<code>shards: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
<dt>

<code>num_shard_bits: vector&lt;u64&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_ShardedBitVector_empty_info"></a>

## Function `empty_info`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_empty_info">empty_info</a>(sender: &signer): <a href="#0x1_ShardedBitVector_BitVectorInfo">ShardedBitVector::BitVectorInfo</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_empty_info">empty_info</a>(sender: &signer
): <a href="#0x1_ShardedBitVector_BitVectorInfo">BitVectorInfo</a> {
    <a href="#0x1_ShardedBitVector_BitVectorInfo">BitVectorInfo</a> {
        primary: <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender),

        locked: <b>false</b>,

        shards: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
        // Size of this vector == number of batches
        num_shard_bits: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    }
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_empty_shard"></a>

## Function `empty_shard`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_empty_shard">empty_shard</a>(primary_address: address): <a href="#0x1_ShardedBitVector_BitVectorShard">ShardedBitVector::BitVectorShard</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_empty_shard">empty_shard</a>(primary_address: address
): <a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a> {
    <a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a> {
        primary: primary_address,
        batches: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    }
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_initialize">initialize</a>(lr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_initialize">initialize</a>(lr_account: &signer) {
    move_to(lr_account, <a href="#0x1_ShardedBitVector_empty_info">empty_info</a>(lr_account));
    move_to(lr_account, <a href="#0x1_ShardedBitVector_empty_shard">empty_shard</a>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(lr_account)));
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_register_as_shard"></a>

## Function `register_as_shard`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_register_as_shard">register_as_shard</a>(sender: &signer, info: &<b>mut</b> <a href="#0x1_ShardedBitVector_BitVectorInfo">ShardedBitVector::BitVectorInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_register_as_shard">register_as_shard</a>(sender: &signer,
                             info: &<b>mut</b> <a href="#0x1_ShardedBitVector_BitVectorInfo">BitVectorInfo</a>,
) {
    <b>assert</b>(!info.locked, 9000);
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> info.shards, <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender));

    move_to(sender, <a href="#0x1_ShardedBitVector_empty_shard">empty_shard</a>(info.primary));
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_lock_info"></a>

## Function `lock_info`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_lock_info">lock_info</a>(sender: &signer, info: &<b>mut</b> <a href="#0x1_ShardedBitVector_BitVectorInfo">ShardedBitVector::BitVectorInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_lock_info">lock_info</a>(sender: &signer,
                     info: &<b>mut</b> <a href="#0x1_ShardedBitVector_BitVectorInfo">BitVectorInfo</a>,
) {
    <b>assert</b>(info.primary == <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender), 9000);
    <b>assert</b>(!info.locked, 9000);
    info.locked = <b>true</b>;
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_time_expired"></a>

## Function `time_expired`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_time_expired">time_expired</a>(expiration_time: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_time_expired">time_expired</a>(expiration_time: u64): bool {
    <a href="LibraTimestamp.md#0x1_LibraTimestamp_now_microseconds">LibraTimestamp::now_microseconds</a>() &gt;= expiration_time
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_div_ceil"></a>

## Function `div_ceil`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_div_ceil">div_ceil</a>(a: u64, b: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_div_ceil">div_ceil</a>(a: u64, b: u64,
): u64 {
    (a + b - 1) / b
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_vector_with_copies"></a>

## Function `vector_with_copies`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_vector_with_copies">vector_with_copies</a>(num_copies: u64, element: u128): vector&lt;u128&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_vector_with_copies">vector_with_copies</a>(num_copies: u64, element: u128,
): vector&lt;u128&gt; {
    <b>let</b> ret = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>();
    <b>let</b> i = 0;
    <b>while</b> (i &lt; num_copies) {
        <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> ret, element);
        i = i + 1;
    };

    ret
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_issue_batch_on_shard"></a>

## Function `issue_batch_on_shard`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_issue_batch_on_shard">issue_batch_on_shard</a>(shard_address: address, primary_address: address, batch_size: u64, duration_microseconds: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_issue_batch_on_shard">issue_batch_on_shard</a>(shard_address: address,
                         primary_address: address,
                         batch_size: u64,
                         duration_microseconds: u64,
): u64 <b>acquires</b> <a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a> {
    <b>let</b> shard = borrow_global_mut&lt;<a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a>&gt;(shard_address);
    <b>assert</b>(shard.primary == primary_address, 9000);

    <b>let</b> batch_id = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&shard.batches);
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> shard.batches, <a href="#0x1_ShardedBitVector_BitVectorBatch">BitVectorBatch</a> {
        boxed_bits: <a href="#0x1_ShardedBitVector_vector_with_copies">vector_with_copies</a>(<a href="#0x1_ShardedBitVector_div_ceil">div_ceil</a>(batch_size, 128), 0),

        expiration_time: <a href="LibraTimestamp.md#0x1_LibraTimestamp_now_microseconds">LibraTimestamp::now_microseconds</a>() + duration_microseconds,
    });

    batch_id
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_issue_batch"></a>

## Function `issue_batch`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_issue_batch">issue_batch</a>(sender: &signer, info: &<b>mut</b> <a href="#0x1_ShardedBitVector_BitVectorInfo">ShardedBitVector::BitVectorInfo</a>, batch_size: u64, duration_microseconds: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_issue_batch">issue_batch</a>(sender: &signer,
                       info: &<b>mut</b> <a href="#0x1_ShardedBitVector_BitVectorInfo">BitVectorInfo</a>,
                       batch_size: u64,
                       duration_microseconds: u64,
): u64 <b>acquires</b> <a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a> {
    <b>let</b> sender_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
    <b>assert</b>(info.primary == sender_address, 9000);
    <b>assert</b>(info.locked, 9000);

    <b>let</b> num_shards = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&info.shards);
    <b>let</b> per_shard_bits = <a href="#0x1_ShardedBitVector_div_ceil">div_ceil</a>(batch_size, num_shards);

    <b>let</b> batch_index = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&info.num_shard_bits);
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> info.num_shard_bits, per_shard_bits);

    <b>let</b> i = 0;
    <b>while</b> (i &lt; num_shards) {
        <b>let</b> shard_address = *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&info.shards, i);
        <b>let</b> new_index = <a href="#0x1_ShardedBitVector_issue_batch_on_shard">issue_batch_on_shard</a>(shard_address,
                                             sender_address,
                                             per_shard_bits,
                                             duration_microseconds);
        <b>assert</b>(batch_index == new_index, 9000);
        i = i + 1;
    };

    batch_index
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_test_and_set_bit_on_shard"></a>

## Function `test_and_set_bit_on_shard`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_test_and_set_bit_on_shard">test_and_set_bit_on_shard</a>(shard_address: address, primary_address: address, batch_index: u64, bit_index: u64, assert_expiry: bool): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_test_and_set_bit_on_shard">test_and_set_bit_on_shard</a>(shard_address: address,
                              primary_address: address,
                              batch_index: u64,
                              bit_index: u64,
                              assert_expiry: bool,
): bool <b>acquires</b> <a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a> {
    <b>let</b> shard = borrow_global_mut&lt;<a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a>&gt;(shard_address);
    <b>assert</b>(shard.primary == primary_address, 9000);

    <b>let</b> batch = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> shard.batches,
                                   batch_index);
    <b>let</b> was_expired = <a href="#0x1_ShardedBitVector_time_expired">time_expired</a>(batch.expiration_time);
    <b>if</b> (was_expired) {
        // If assert_expiry == <b>true</b>, we will <b>assert</b>.
        <b>assert</b>(!assert_expiry, 9000);
        // Otherwise, just <b>return</b> <b>true</b> (not set now).
        <b>return</b> <b>true</b>
    };

    // Not expired.
    <b>let</b> box_index = bit_index / 128;
    <b>let</b> pack_index = bit_index % 128;
    <b>let</b> bitmask = (1 &lt;&lt; (pack_index <b>as</b> u8));
    <b>let</b> target_box = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> batch.boxed_bits, box_index);

    <b>let</b> test_status: bool = (*target_box & bitmask) == bitmask;
    *target_box = *target_box | bitmask;
    test_status
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_test_and_set_bit"></a>

## Function `test_and_set_bit`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_test_and_set_bit">test_and_set_bit</a>(info: &<a href="#0x1_ShardedBitVector_BitVectorInfo">ShardedBitVector::BitVectorInfo</a>, batch_index: u64, bit_index: u64, assert_expiry: bool): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_test_and_set_bit">test_and_set_bit</a>(info: &<a href="#0x1_ShardedBitVector_BitVectorInfo">BitVectorInfo</a>,
                            batch_index: u64,
                            bit_index: u64,
                            assert_expiry: bool,
): bool <b>acquires</b> <a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a> {
    <b>assert</b>(info.locked, 9000);

    <b>let</b> per_shard_bits = *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&info.num_shard_bits,
                                         batch_index);
    <b>let</b> shard_index = bit_index / per_shard_bits;
    <b>let</b> shard_address = *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&info.shards,
                                        shard_index);

    <a href="#0x1_ShardedBitVector_test_and_set_bit_on_shard">test_and_set_bit_on_shard</a>(shard_address,
                              info.primary,
                              batch_index,
                              bit_index % per_shard_bits,
                              assert_expiry)
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_clear_vector"></a>

## Function `clear_vector`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_clear_vector">clear_vector</a>(v: &<b>mut</b> vector&lt;u128&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_clear_vector">clear_vector</a>(v: &<b>mut</b> vector&lt;u128&gt;,) {
    <b>let</b> length = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(v);

    <b>let</b> i = 0;
    <b>while</b> (i &lt; length) {
        <a href="Vector.md#0x1_Vector_pop_back">Vector::pop_back</a>(v);
        i = i + 1;
    };
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_clear_bits_if_expired"></a>

## Function `clear_bits_if_expired`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_clear_bits_if_expired">clear_bits_if_expired</a>(bits_array: &<b>mut</b> vector&lt;u128&gt;, expiration_time: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVector_clear_bits_if_expired">clear_bits_if_expired</a>(bits_array: &<b>mut</b> vector&lt;u128&gt;,
                          expiration_time: u64,
): bool {
    <b>let</b> expired = <a href="#0x1_ShardedBitVector_time_expired">time_expired</a>(expiration_time);

    <b>let</b> was_empty = <a href="Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(bits_array);
    <b>if</b> (expired) {
        <a href="#0x1_ShardedBitVector_clear_vector">clear_vector</a>(bits_array);
    };

    expired && !was_empty
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_compress_expired_batch_on_shard"></a>

## Function `compress_expired_batch_on_shard`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_compress_expired_batch_on_shard">compress_expired_batch_on_shard</a>(shard_address: address, primary_address: address, batch_index: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_compress_expired_batch_on_shard">compress_expired_batch_on_shard</a>(shard_address: address,
                                           primary_address: address,
                                           batch_index: u64,
): bool <b>acquires</b> <a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a> {
    <b>let</b> shard = borrow_global_mut&lt;<a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a>&gt;(shard_address);
    <b>assert</b>(shard.primary == primary_address, 9000);

    <b>let</b> batch = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> shard.batches, batch_index);
    <a href="#0x1_ShardedBitVector_clear_bits_if_expired">clear_bits_if_expired</a>(&<b>mut</b> batch.boxed_bits,
                          batch.expiration_time)
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_compress_expired_batch"></a>

## Function `compress_expired_batch`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_compress_expired_batch">compress_expired_batch</a>(info: &<a href="#0x1_ShardedBitVector_BitVectorInfo">ShardedBitVector::BitVectorInfo</a>, batch_index: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_compress_expired_batch">compress_expired_batch</a>(info: &<a href="#0x1_ShardedBitVector_BitVectorInfo">BitVectorInfo</a>,
                                  batch_index: u64,
): bool <b>acquires</b> <a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a> {
    <b>assert</b>(info.locked, 9000);

    <b>let</b> num_shards = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&info.shards);

    <b>let</b> compressed = <a href="Option.md#0x1_Option_none">Option::none</a>&lt;bool&gt;();
    <b>let</b> i = 0;
    <b>while</b> (i &lt; num_shards) {
        <b>let</b> shard_address = *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&info.shards, i);
        <b>let</b> i_compressed = <a href="#0x1_ShardedBitVector_compress_expired_batch_on_shard">compress_expired_batch_on_shard</a>(shard_address,
                                                           info.primary,
                                                           batch_index);
        <b>assert</b>(<a href="Option.md#0x1_Option_is_none">Option::is_none</a>(&compressed) ||
               *<a href="Option.md#0x1_Option_borrow">Option::borrow</a>(&compressed) == i_compressed, 9000);
        compressed = <a href="Option.md#0x1_Option_some">Option::some</a>(i_compressed);

        i = i + 1;
    };

    *<a href="Option.md#0x1_Option_borrow">Option::borrow</a>(&compressed)
}
</code></pre>



</details>

<a name="0x1_ShardedBitVector_compress_expired_batches"></a>

## Function `compress_expired_batches`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_compress_expired_batches">compress_expired_batches</a>(info: &<a href="#0x1_ShardedBitVector_BitVectorInfo">ShardedBitVector::BitVectorInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVector_compress_expired_batches">compress_expired_batches</a>(info: &<a href="#0x1_ShardedBitVector_BitVectorInfo">BitVectorInfo</a>,
) <b>acquires</b> <a href="#0x1_ShardedBitVector_BitVectorShard">BitVectorShard</a> {
    <b>let</b> num_batches = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&info.num_shard_bits);

    <b>let</b> i = 0;
    <b>while</b> (i &lt; num_batches) {
        <a href="#0x1_ShardedBitVector_compress_expired_batch">compress_expired_batch</a>(info, i);
        i = i + 1;
    };
}
</code></pre>



</details>
