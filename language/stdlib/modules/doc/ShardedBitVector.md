
<a name="0x1_ShardedBitVectorBatches"></a>

# Module `0x1::ShardedBitVectorBatches`

### Table of Contents

-  [Resource `BitVectorBatch`](#0x1_ShardedBitVectorBatches_BitVectorBatch)
-  [Resource `BitVectorBatchesShard`](#0x1_ShardedBitVectorBatches_BitVectorBatchesShard)
-  [Resource `BitVectorBatchesInfo`](#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo)
-  [Function `empty_info`](#0x1_ShardedBitVectorBatches_empty_info)
-  [Function `empty_shard`](#0x1_ShardedBitVectorBatches_empty_shard)
-  [Function `initialize`](#0x1_ShardedBitVectorBatches_initialize)
-  [Function `register_as_shard`](#0x1_ShardedBitVectorBatches_register_as_shard)
-  [Function `finish_shard_registration`](#0x1_ShardedBitVectorBatches_finish_shard_registration)
-  [Function `time_expired`](#0x1_ShardedBitVectorBatches_time_expired)
-  [Function `div_ceil`](#0x1_ShardedBitVectorBatches_div_ceil)
-  [Function `issue_batch_on_shard`](#0x1_ShardedBitVectorBatches_issue_batch_on_shard)
-  [Function `min`](#0x1_ShardedBitVectorBatches_min)
-  [Function `issue_batch`](#0x1_ShardedBitVectorBatches_issue_batch)
-  [Function `test_and_set_bit_on_shard`](#0x1_ShardedBitVectorBatches_test_and_set_bit_on_shard)
-  [Function `test_and_set_bit`](#0x1_ShardedBitVectorBatches_test_and_set_bit)
-  [Function `compress_expired_batch_on_shard`](#0x1_ShardedBitVectorBatches_compress_expired_batch_on_shard)
-  [Function `compress_expired_batch`](#0x1_ShardedBitVectorBatches_compress_expired_batch)
-  [Function `compress_expired_batches`](#0x1_ShardedBitVectorBatches_compress_expired_batches)



<a name="0x1_ShardedBitVectorBatches_BitVectorBatch"></a>

## Resource `BitVectorBatch`

A resouce that contains actual bits stored on a shard per batch.


<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatch">BitVectorBatch</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>stored_bits: vector&lt;u128&gt;</code>
</dt>
<dd>
 bit-packed. TODO: generalize bit-packing factor.
</dd>
<dt>

<code>expiration_time: u64</code>
</dt>
<dd>
 Expiration time of the batch (for recycling).
</dd>
</dl>


</details>

<a name="0x1_ShardedBitVectorBatches_BitVectorBatchesShard"></a>

## Resource `BitVectorBatchesShard`

A resource contains meta-data for each shard and a vector
pointing to BitVectorBatch for each batch. A shard currently is
dedicated to a single ShardedBitVectorBatches data-structure, i.e.
it can't store parts of two different shared bit vectors.


<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>primary: address</code>
</dt>
<dd>
 Address of the primary account for sharding.
 Primary can also be one of its shards.
</dd>
<dt>

<code>batch_store: vector&lt;<a href="#0x1_ShardedBitVectorBatches_BitVectorBatch">ShardedBitVectorBatches::BitVectorBatch</a>&gt;</code>
</dt>
<dd>
 Batches of a bit vector stored on the given shard.
</dd>
</dl>


</details>

<a name="0x1_ShardedBitVectorBatches_BitVectorBatchesInfo"></a>

## Resource `BitVectorBatchesInfo`

A resource containing meta-data for a SharedBitVectorBatches
data-structure.


<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">BitVectorBatchesInfo</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>primary: address</code>
</dt>
<dd>
 The address of the primary account for the
 ShardedBitVectorBatches data-structure. Info should be
 published on primary's account.
</dd>
<dt>

<code>locked: bool</code>
</dt>
<dd>
 The vector of shard addresses is finalized. Before finalized,
 the ShardedBitVectorBatches storage cannot be used, and once
 finalized, new shards can no longer be registered.
</dd>
<dt>

<code>shards: vector&lt;address&gt;</code>
</dt>
<dd>
 Addresses of the shards, in order. Note: Primary can also
 register its address as one of the shards.
</dd>
<dt>

<code>num_bits_per_shard: u64</code>
</dt>
<dd>
 Number of bits stored per shard per batch. Once a shard stores
 num_bits_per_shard bits, the next shard stores next bits.
 The last shard stores as many bits as necessary. Formally,
 the invariant is that only the last shard can store
 >num_bits_per_shard bits, other shards always store
 <= num_bits_per_shard bits, and if a shard stores
 <num_bits_per_shard bits, then all previous shards must be
 storing exactly =num_bits_per_shard bits and all later shards
 must store 0 bits.
</dd>
<dt>

<code>batch_total_bits: vector&lt;u64&gt;</code>
</dt>
<dd>
 Number of total bits in a batch, length of the vector is
 equal to the number of batches.
</dd>
</dl>


</details>

<a name="0x1_ShardedBitVectorBatches_empty_info"></a>

## Function `empty_info`

Returns an empty BitVectorBatchInfo resource, to be published on the
primary account address.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_empty_info">empty_info</a>(sender: &signer, max_bits_per_shard: u64): <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">ShardedBitVectorBatches::BitVectorBatchesInfo</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_empty_info">empty_info</a>(sender: &signer,
                      max_bits_per_shard: u64,
): <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">BitVectorBatchesInfo</a> {
    <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">BitVectorBatchesInfo</a> {
        primary: <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender),

        locked: <b>false</b>,

        shards: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
        num_bits_per_shard: max_bits_per_shard,
        batch_total_bits: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    }
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_empty_shard"></a>

## Function `empty_shard`

Returns an empty per-shard bit vector storage. To be published
on each shard's account address (possibly on primary's account
address as well if it is registered as a shard itself).


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVectorBatches_empty_shard">empty_shard</a>(primary_address: address): <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">ShardedBitVectorBatches::BitVectorBatchesShard</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVectorBatches_empty_shard">empty_shard</a>(primary_address: address
): <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a> {
    <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a> {
        primary: primary_address,
        batch_store: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
    }
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_initialize"></a>

## Function `initialize`

Can only be called during genesis with libra root account.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_initialize">initialize</a>(lr_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_initialize">initialize</a>(lr_account: &signer) {
    <a href="LibraTimestamp.md#0x1_LibraTimestamp_assert_genesis">LibraTimestamp::assert_genesis</a>();

    // Initialize empty <b>resource</b> types.
    move_to(lr_account, <a href="#0x1_ShardedBitVectorBatches_empty_info">empty_info</a>(lr_account, 1000));
    // TODO: bring back when publish_money_orders doesn't by default
    // register itself <b>as</b> shard (TODO in <a href="MoneyOrder.md#0x1_MoneyOrder">MoneyOrder</a> <b>module</b>) - right now
    // it does leading <b>to</b> a genesis <b>abort</b> w. RESOURCE_ALREADY_EXISTS.
    // move_to(lr_account, <a href="#0x1_ShardedBitVectorBatches_empty_shard">empty_shard</a>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(lr_account)));
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_register_as_shard"></a>

## Function `register_as_shard`

An account calls this function to be registered as a shard on
a BitVectorBatches storage corresponding to the provided info (info
determines the primary). Registration is only possible while
locked = false, otherwise an assert is triggered.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_register_as_shard">register_as_shard</a>(sender: &signer, info: &<b>mut</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">ShardedBitVectorBatches::BitVectorBatchesInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_register_as_shard">register_as_shard</a>(sender: &signer,
                             info: &<b>mut</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">BitVectorBatchesInfo</a>,
) {
    // Assert that registration hasn't already concluded.
    <b>assert</b>(!info.locked, 9000);

    <b>let</b> shard_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
    // Ensure that shard is not already registered - registering the
    // same account twice is not possible.
    <b>assert</b>(!<a href="Vector.md#0x1_Vector_contains">Vector::contains</a>(&info.shards, &shard_address), 9000);
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> info.shards, shard_address);

    // This can still fail <b>if</b> the shard is registered for another
    // info. If we would like <b>to</b> enable same account <b>to</b> serve <b>as</b>
    // shard for multiple BitVectorBatches data-structures, we need
    // the way <b>to</b> distinguish the shard types - i.e. for instance
    // by using (<b>if</b> it was available) an Address/Int <b>to</b> type paradigm.
    // Note: a <b>native</b> implementation that internally manages *dedicated*
    // data/shard accounts wouldn't have this problem.
    move_to(sender, <a href="#0x1_ShardedBitVectorBatches_empty_shard">empty_shard</a>(info.primary));
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_finish_shard_registration"></a>

## Function `finish_shard_registration`

Locks the info to conclude the shard registration, can only
be called by the primary.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_finish_shard_registration">finish_shard_registration</a>(sender: &signer, info: &<b>mut</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">ShardedBitVectorBatches::BitVectorBatchesInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_finish_shard_registration">finish_shard_registration</a>(sender: &signer,
                                     info: &<b>mut</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">BitVectorBatchesInfo</a>,
) {
    <b>assert</b>(info.primary == <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender), 9000);

    <b>assert</b>(!info.locked, 9000);
    info.locked = <b>true</b>;
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_time_expired"></a>

## Function `time_expired`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVectorBatches_time_expired">time_expired</a>(expiration_time: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVectorBatches_time_expired">time_expired</a>(expiration_time: u64): bool {
    <a href="LibraTimestamp.md#0x1_LibraTimestamp_now_microseconds">LibraTimestamp::now_microseconds</a>() &gt;= expiration_time
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_div_ceil"></a>

## Function `div_ceil`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVectorBatches_div_ceil">div_ceil</a>(a: u64, b: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVectorBatches_div_ceil">div_ceil</a>(a: u64, b: u64,
): u64 {
    (a + b - 1) / b
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_issue_batch_on_shard"></a>

## Function `issue_batch_on_shard`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVectorBatches_issue_batch_on_shard">issue_batch_on_shard</a>(shard_address: address, primary_address: address, num_bits: u64, duration_microseconds: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVectorBatches_issue_batch_on_shard">issue_batch_on_shard</a>(shard_address: address,
                         primary_address: address,
                         num_bits: u64,
                         duration_microseconds: u64,
): u64 <b>acquires</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a> {
    // Note: <b>if</b> shards were allowed <b>to</b> be shared (currently dedicated)
    // then this would require identifying the correct one (<b>as</b> a
    // specialization of <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a>.
    <b>let</b> shard = borrow_global_mut&lt;<a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a>&gt;(shard_address);
    <b>assert</b>(shard.primary == primary_address, 9000);

    <b>let</b> batch_id = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&shard.batch_store);
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> shard.batch_store, <a href="#0x1_ShardedBitVectorBatches_BitVectorBatch">BitVectorBatch</a> {
        stored_bits: <a href="Vector.md#0x1_Vector_initialize">Vector::initialize</a>(0, <a href="#0x1_ShardedBitVectorBatches_div_ceil">div_ceil</a>(num_bits, 128)),

        expiration_time: <a href="LibraTimestamp.md#0x1_LibraTimestamp_now_microseconds">LibraTimestamp::now_microseconds</a>() +
            duration_microseconds,
    });

    batch_id
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_min"></a>

## Function `min`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVectorBatches_min">min</a>(a: u64, b: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVectorBatches_min">min</a>(a: u64, b: u64): u64 {
    <b>if</b> (a &lt; b) {
        <b>return</b> a
    };

    b
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_issue_batch"></a>

## Function `issue_batch`

Issue a batch on the sharded BitVectorBatches storage corresponding
to the provided info. Can only be called by the primary.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_issue_batch">issue_batch</a>(sender: &signer, info: &<b>mut</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">ShardedBitVectorBatches::BitVectorBatchesInfo</a>, batch_size_bits: u64, duration_microseconds: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_issue_batch">issue_batch</a>(sender: &signer,
                       info: &<b>mut</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">BitVectorBatchesInfo</a>,
                       batch_size_bits: u64,
                       duration_microseconds: u64,
): u64 <b>acquires</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a> {
    <b>let</b> sender_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
    <b>assert</b>(info.primary == sender_address, 9000);

    // Assert that shard registration has concluded.
    <b>assert</b>(info.locked, 9000);

    <b>let</b> batch_index = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&info.batch_total_bits);
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> info.batch_total_bits, batch_size_bits);

    <b>let</b> num_shards = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&info.shards);
    <b>let</b> bits_to_store = batch_size_bits;
    <b>let</b> i = 0;
    <b>while</b> (i &lt; num_shards && bits_to_store &gt; 0) {
        <b>let</b> shard_address = *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&info.shards, i);

        <b>let</b> num_bits_on_shard =
            <a href="#0x1_ShardedBitVectorBatches_min">min</a>(info.num_bits_per_shard,
                bits_to_store);
        <b>if</b> (i == num_shards - 1) {
            // Last shard must store all remaining bits in the batch.
            num_bits_on_shard = bits_to_store;
        };

        <b>let</b> new_index = <a href="#0x1_ShardedBitVectorBatches_issue_batch_on_shard">issue_batch_on_shard</a>(shard_address,
                                             sender_address,
                                             num_bits_on_shard,
                                             duration_microseconds);
        // Assert the batch_index is consistent on shard's storage.
        <b>assert</b>(batch_index == new_index, 9000);

        bits_to_store = bits_to_store - num_bits_on_shard;
        i = i + 1;
    };

    batch_index
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_test_and_set_bit_on_shard"></a>

## Function `test_and_set_bit_on_shard`



<pre><code><b>fun</b> <a href="#0x1_ShardedBitVectorBatches_test_and_set_bit_on_shard">test_and_set_bit_on_shard</a>(shard_address: address, primary_address: address, batch_index: u64, bit_index: u64, assert_expiry: bool): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_ShardedBitVectorBatches_test_and_set_bit_on_shard">test_and_set_bit_on_shard</a>(shard_address: address,
                              primary_address: address,
                              batch_index: u64,
                              bit_index: u64,
                              assert_expiry: bool,
): bool <b>acquires</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a> {
    <b>let</b> shard = borrow_global_mut&lt;<a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a>&gt;(shard_address);
    <b>assert</b>(shard.primary == primary_address, 9000);

    <b>let</b> batch = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> shard.batch_store,
                                   batch_index);
    <b>let</b> was_expired = <a href="#0x1_ShardedBitVectorBatches_time_expired">time_expired</a>(batch.expiration_time);
    <b>if</b> (was_expired) {
        // If assert_expiry == <b>true</b>, we will <b>assert</b>.
        <b>assert</b>(!assert_expiry, 9000);
        // Otherwise, just <b>return</b> <b>true</b> (not set now).
        <b>return</b> <b>true</b>
    };

    // Not expired.
    <b>let</b> store_index = bit_index / 128;
    <b>let</b> packed_index = bit_index % 128;
    <b>let</b> bitmask = (1 &lt;&lt; (packed_index <b>as</b> u8));
    <b>let</b> target_store = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> batch.stored_bits,
                                          store_index);

    <b>let</b> test_status: bool = (*target_store & bitmask) == bitmask;
    *target_store = *target_store | bitmask;
    test_status
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_test_and_set_bit"></a>

## Function `test_and_set_bit`

Function that tests and sets a bit specified by the batch and index
with the batch in the ShardedBitVectorBatches data-structure
corresponding to the info. The function is public without signer,
and the access control is the responsibility of the info holder.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_test_and_set_bit">test_and_set_bit</a>(info: &<a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">ShardedBitVectorBatches::BitVectorBatchesInfo</a>, batch_index: u64, bit_index: u64, assert_expiry: bool): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_test_and_set_bit">test_and_set_bit</a>(info: &<a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">BitVectorBatchesInfo</a>,
                            batch_index: u64,
                            bit_index: u64,
                            assert_expiry: bool,
): bool <b>acquires</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a> {
    <b>assert</b>(info.locked, 9000);

    <b>let</b> num_shards = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&info.shards);

    <b>let</b> shard_index = bit_index / info.num_bits_per_shard;
    <b>let</b> bit_index_on_shard = bit_index % info.num_bits_per_shard;
    <b>if</b> (shard_index &gt;= num_shards) {
        // The last shard contains all remaining bits in every batch.
        shard_index = num_shards - 1;
        bit_index_on_shard =
            bit_index - (num_shards - 1) * info.num_bits_per_shard;
    };

    <b>let</b> shard_address = *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&info.shards,
                                        shard_index);
    <a href="#0x1_ShardedBitVectorBatches_test_and_set_bit_on_shard">test_and_set_bit_on_shard</a>(shard_address,
                              info.primary,
                              batch_index,
                              bit_index_on_shard,
                              assert_expiry)
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_compress_expired_batch_on_shard"></a>

## Function `compress_expired_batch_on_shard`

If a batch has expired, clear its stored_bits on a given shard to
save memory and return true.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_compress_expired_batch_on_shard">compress_expired_batch_on_shard</a>(shard_address: address, primary_address: address, batch_index: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_compress_expired_batch_on_shard">compress_expired_batch_on_shard</a>(shard_address: address,
                                           primary_address: address,
                                           batch_index: u64,
): bool <b>acquires</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a> {
    <b>let</b> shard = borrow_global_mut&lt;<a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a>&gt;(shard_address);
    <b>assert</b>(shard.primary == primary_address, 9000);

    <b>let</b> batch = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> shard.batch_store, batch_index);

    <b>if</b> (<a href="#0x1_ShardedBitVectorBatches_time_expired">time_expired</a>(batch.expiration_time)) {
        <a href="Vector.md#0x1_Vector_clear">Vector::clear</a>(&<b>mut</b> batch.stored_bits);
        <b>return</b> <b>true</b>
    };

    <b>false</b>
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_compress_expired_batch"></a>

## Function `compress_expired_batch`

If a batch has expired, clear its stored_bits across shards to
save memory and return true.


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_compress_expired_batch">compress_expired_batch</a>(info: &<a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">ShardedBitVectorBatches::BitVectorBatchesInfo</a>, batch_index: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_compress_expired_batch">compress_expired_batch</a>(info: &<a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">BitVectorBatchesInfo</a>,
                                  batch_index: u64,
): bool <b>acquires</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a> {
    <b>assert</b>(info.locked, 9000);

    <b>let</b> num_shards = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&info.shards);

    <b>let</b> compressed = <a href="Option.md#0x1_Option_none">Option::none</a>&lt;bool&gt;();
    <b>let</b> i = 0;
    <b>while</b> (i &lt; num_shards) {
        <b>let</b> shard_address = *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&info.shards, i);
        <b>let</b> i_compressed = <a href="#0x1_ShardedBitVectorBatches_compress_expired_batch_on_shard">compress_expired_batch_on_shard</a>(shard_address,
                                                           info.primary,
                                                           batch_index);
        // Assert that compression results are consistent across batch.
        <b>assert</b>(<a href="Option.md#0x1_Option_is_none">Option::is_none</a>(&compressed) ||
               *<a href="Option.md#0x1_Option_borrow">Option::borrow</a>(&compressed) == i_compressed, 9000);
        compressed = <a href="Option.md#0x1_Option_some">Option::some</a>(i_compressed);

        i = i + 1;
    };

    *<a href="Option.md#0x1_Option_borrow">Option::borrow</a>(&compressed)
}
</code></pre>



</details>

<a name="0x1_ShardedBitVectorBatches_compress_expired_batches"></a>

## Function `compress_expired_batches`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_compress_expired_batches">compress_expired_batches</a>(info: &<a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">ShardedBitVectorBatches::BitVectorBatchesInfo</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_ShardedBitVectorBatches_compress_expired_batches">compress_expired_batches</a>(info: &<a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesInfo">BitVectorBatchesInfo</a>,
) <b>acquires</b> <a href="#0x1_ShardedBitVectorBatches_BitVectorBatchesShard">BitVectorBatchesShard</a> {
    <b>let</b> num_batches = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&info.batch_total_bits);

    <b>let</b> i = 0;
    <b>while</b> (i &lt; num_batches) {
        <a href="#0x1_ShardedBitVectorBatches_compress_expired_batch">compress_expired_batch</a>(info, i);
        i = i + 1;
    };
}
</code></pre>



</details>
