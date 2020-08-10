
<a name="0x1_MoneyOrder"></a>

# Module `0x1::MoneyOrder`

### Table of Contents

-  [Resource `MoneyOrderCoin`](#0x1_MoneyOrder_MoneyOrderCoin)
-  [Resource `MoneyOrderCoinVector`](#0x1_MoneyOrder_MoneyOrderCoinVector)
-  [Resource `MoneyOrderBatch`](#0x1_MoneyOrder_MoneyOrderBatch)
-  [Resource `MoneyOrders`](#0x1_MoneyOrder_MoneyOrders)
-  [Struct `MoneyOrderDescriptor`](#0x1_MoneyOrder_MoneyOrderDescriptor)
-  [Struct `IssuedMoneyOrderEvent`](#0x1_MoneyOrder_IssuedMoneyOrderEvent)
-  [Struct `CanceledMoneyOrderEvent`](#0x1_MoneyOrder_CanceledMoneyOrderEvent)
-  [Struct `RedeemedMoneyOrderEvent`](#0x1_MoneyOrder_RedeemedMoneyOrderEvent)
-  [Function `money_order_descriptor`](#0x1_MoneyOrder_money_order_descriptor)
-  [Function `mint_money_order_coin`](#0x1_MoneyOrder_mint_money_order_coin)
-  [Function `initialize_money_orders`](#0x1_MoneyOrder_initialize_money_orders)
-  [Function `time_expired`](#0x1_MoneyOrder_time_expired)
-  [Function `div_ceil`](#0x1_MoneyOrder_div_ceil)
-  [Function `vector_with_copies`](#0x1_MoneyOrder_vector_with_copies)
-  [Function `issue_money_order_batch`](#0x1_MoneyOrder_issue_money_order_batch)
-  [Function `issue_money_order`](#0x1_MoneyOrder_issue_money_order)
-  [Function `verify_issuer_signature`](#0x1_MoneyOrder_verify_issuer_signature)
-  [Function `verify_user_signature`](#0x1_MoneyOrder_verify_user_signature)
-  [Function `test_and_set_order_status`](#0x1_MoneyOrder_test_and_set_order_status)
-  [Function `cancel_order_impl`](#0x1_MoneyOrder_cancel_order_impl)
-  [Function `issuer_cancel_money_order`](#0x1_MoneyOrder_issuer_cancel_money_order)
-  [Function `redeem_money_order`](#0x1_MoneyOrder_redeem_money_order)
-  [Function `index_of_coin`](#0x1_MoneyOrder_index_of_coin)
-  [Function `money_order_coin_balance`](#0x1_MoneyOrder_money_order_coin_balance)
-  [Function `init_coins_money_order`](#0x1_MoneyOrder_init_coins_money_order)
-  [Function `deposit_money_order`](#0x1_MoneyOrder_deposit_money_order)
-  [Function `cancel_money_order`](#0x1_MoneyOrder_cancel_money_order)
-  [Function `clear_vector`](#0x1_MoneyOrder_clear_vector)
-  [Function `clear_statuses_if_expired`](#0x1_MoneyOrder_clear_statuses_if_expired)
-  [Function `compress_expired_batch`](#0x1_MoneyOrder_compress_expired_batch)
-  [Function `compress_expired_batches`](#0x1_MoneyOrder_compress_expired_batches)



<a name="0x1_MoneyOrder_MoneyOrderCoin"></a>

## Resource `MoneyOrderCoin`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrderCoin</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>amount: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>issuer_address: address</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MoneyOrder_MoneyOrderCoinVector"></a>

## Resource `MoneyOrderCoinVector`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_MoneyOrder_MoneyOrderCoinVector">MoneyOrderCoinVector</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>coins: vector&lt;<a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrder::MoneyOrderCoin</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MoneyOrder_MoneyOrderBatch"></a>

## Resource `MoneyOrderBatch`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_MoneyOrder_MoneyOrderBatch">MoneyOrderBatch</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>order_status: vector&lt;u8&gt;</code>
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

<a name="0x1_MoneyOrder_MoneyOrders"></a>

## Resource `MoneyOrders`



<pre><code><b>resource</b> <b>struct</b> <a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>batches: vector&lt;<a href="#0x1_MoneyOrder_MoneyOrderBatch">MoneyOrder::MoneyOrderBatch</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>

<code>public_key: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>

<code>balance: <a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrder::MoneyOrderCoin</a></code>
</dt>
<dd>

</dd>
<dt>

<code>issued_events: <a href="Event.md#0x1_Event_EventHandle">Event::EventHandle</a>&lt;<a href="#0x1_MoneyOrder_IssuedMoneyOrderEvent">MoneyOrder::IssuedMoneyOrderEvent</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>

<code>canceled_events: <a href="Event.md#0x1_Event_EventHandle">Event::EventHandle</a>&lt;<a href="#0x1_MoneyOrder_CanceledMoneyOrderEvent">MoneyOrder::CanceledMoneyOrderEvent</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>

<code>redeemed_events: <a href="Event.md#0x1_Event_EventHandle">Event::EventHandle</a>&lt;<a href="#0x1_MoneyOrder_RedeemedMoneyOrderEvent">MoneyOrder::RedeemedMoneyOrderEvent</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MoneyOrder_MoneyOrderDescriptor"></a>

## Struct `MoneyOrderDescriptor`



<pre><code><b>struct</b> <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrderDescriptor</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>amount: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>issuer_address: address</code>
</dt>
<dd>

</dd>
<dt>

<code>batch_index: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>order_index: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>user_public_key: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MoneyOrder_IssuedMoneyOrderEvent"></a>

## Struct `IssuedMoneyOrderEvent`



<pre><code><b>struct</b> <a href="#0x1_MoneyOrder_IssuedMoneyOrderEvent">IssuedMoneyOrderEvent</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>batch_index: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>num_orders: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MoneyOrder_CanceledMoneyOrderEvent"></a>

## Struct `CanceledMoneyOrderEvent`



<pre><code><b>struct</b> <a href="#0x1_MoneyOrder_CanceledMoneyOrderEvent">CanceledMoneyOrderEvent</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>batch_index: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>order_index: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MoneyOrder_RedeemedMoneyOrderEvent"></a>

## Struct `RedeemedMoneyOrderEvent`



<pre><code><b>struct</b> <a href="#0x1_MoneyOrder_RedeemedMoneyOrderEvent">RedeemedMoneyOrderEvent</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>

<code>amount: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>batch_index: u64</code>
</dt>
<dd>

</dd>
<dt>

<code>order_index: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_MoneyOrder_money_order_descriptor"></a>

## Function `money_order_descriptor`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_money_order_descriptor">money_order_descriptor</a>(_sender: &signer, amount: u64, issuer_address: address, batch_index: u64, order_index: u64, user_public_key: vector&lt;u8&gt;): <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrder::MoneyOrderDescriptor</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_money_order_descriptor">money_order_descriptor</a>(
    _sender: &signer,
    amount: u64,
    issuer_address: address,
    batch_index: u64,
    order_index: u64,
    user_public_key: vector&lt;u8&gt;,
): <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrderDescriptor</a> {
    <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrderDescriptor</a> {
        amount: amount,
        issuer_address: issuer_address,
        batch_index: batch_index,
        order_index: order_index,
        user_public_key: user_public_key
    }
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_mint_money_order_coin"></a>

## Function `mint_money_order_coin`



<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_mint_money_order_coin">mint_money_order_coin</a>(amount: u64, issuer_address: address): <a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrder::MoneyOrderCoin</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_mint_money_order_coin">mint_money_order_coin</a>(amount: u64,
                          issuer_address: address,
): <a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrderCoin</a> {
    <a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrderCoin</a> {
        amount: amount,
        issuer_address: issuer_address,
    }
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_initialize_money_orders"></a>

## Function `initialize_money_orders`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_initialize_money_orders">initialize_money_orders</a>(issuer: &signer, public_key: vector&lt;u8&gt;, starting_balance: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_initialize_money_orders">initialize_money_orders</a>(issuer: &signer,
                                   public_key: vector&lt;u8&gt;,
                                   starting_balance: u64,
) {
    move_to(issuer, <a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a> {
        batches: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
        public_key: public_key,
        balance: <a href="#0x1_MoneyOrder_mint_money_order_coin">mint_money_order_coin</a>(starting_balance, <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer)),
        issued_events: <a href="Event.md#0x1_Event_new_event_handle">Event::new_event_handle</a>&lt;<a href="#0x1_MoneyOrder_IssuedMoneyOrderEvent">IssuedMoneyOrderEvent</a>&gt;(issuer),
        canceled_events: <a href="Event.md#0x1_Event_new_event_handle">Event::new_event_handle</a>&lt;<a href="#0x1_MoneyOrder_CanceledMoneyOrderEvent">CanceledMoneyOrderEvent</a>&gt;(issuer),
        redeemed_events: <a href="Event.md#0x1_Event_new_event_handle">Event::new_event_handle</a>&lt;<a href="#0x1_MoneyOrder_RedeemedMoneyOrderEvent">RedeemedMoneyOrderEvent</a>&gt;(issuer),
    });
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_time_expired"></a>

## Function `time_expired`



<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_time_expired">time_expired</a>(expiration_time: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_time_expired">time_expired</a>(expiration_time: u64): bool {
    <a href="LibraTimestamp.md#0x1_LibraTimestamp_now_microseconds">LibraTimestamp::now_microseconds</a>() &gt;= expiration_time
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_div_ceil"></a>

## Function `div_ceil`



<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_div_ceil">div_ceil</a>(a: u64, b: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_div_ceil">div_ceil</a>(a: u64, b: u64,
): u64 {
    (a + b - 1) / b
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_vector_with_copies"></a>

## Function `vector_with_copies`



<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_vector_with_copies">vector_with_copies</a>(num_copies: u64, element: u8): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_vector_with_copies">vector_with_copies</a>(num_copies: u64, element: u8,
): vector&lt;u8&gt; {
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

<a name="0x1_MoneyOrder_issue_money_order_batch"></a>

## Function `issue_money_order_batch`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_issue_money_order_batch">issue_money_order_batch</a>(issuer: &signer, batch_size: u64, validity_microseconds: u64, grace_period_microseconds: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_issue_money_order_batch">issue_money_order_batch</a>(issuer: &signer,
                                   batch_size: u64,
                                   validity_microseconds: u64,
                                   grace_period_microseconds: u64,
) <b>acquires</b> <a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a> {
    <b>let</b> status = <a href="#0x1_MoneyOrder_vector_with_copies">vector_with_copies</a>(<a href="#0x1_MoneyOrder_div_ceil">div_ceil</a>(batch_size, 8), 0);

    <b>let</b> orders = borrow_global_mut&lt;<a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer));
    <b>let</b> duration_microseconds = validity_microseconds + grace_period_microseconds;

    <b>let</b> batch_id = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&orders.batches);
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> orders.batches, <a href="#0x1_MoneyOrder_MoneyOrderBatch">MoneyOrderBatch</a> {
        order_status: status,
        expiration_time: <a href="LibraTimestamp.md#0x1_LibraTimestamp_now_microseconds">LibraTimestamp::now_microseconds</a>() + duration_microseconds,
    });

    <a href="Event.md#0x1_Event_emit_event">Event::emit_event</a>&lt;<a href="#0x1_MoneyOrder_IssuedMoneyOrderEvent">IssuedMoneyOrderEvent</a>&gt;(
        &<b>mut</b> orders.issued_events,
        <a href="#0x1_MoneyOrder_IssuedMoneyOrderEvent">IssuedMoneyOrderEvent</a> {
            batch_index: batch_id,
            num_orders: batch_size,
        }
    );
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_issue_money_order"></a>

## Function `issue_money_order`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_issue_money_order">issue_money_order</a>(issuer: &signer, validity_microseconds: u64, grace_period_microseconds: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_issue_money_order">issue_money_order</a>(issuer: &signer,
                             validity_microseconds: u64,
                             grace_period_microseconds: u64,
) <b>acquires</b> <a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a> {
    <a href="#0x1_MoneyOrder_issue_money_order_batch">issue_money_order_batch</a>(issuer,
                            1,
                            validity_microseconds,
                            grace_period_microseconds)
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_verify_issuer_signature"></a>

## Function `verify_issuer_signature`



<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_verify_issuer_signature">verify_issuer_signature</a>(money_order_descriptor: <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrder::MoneyOrderDescriptor</a>, issuer_signature: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_verify_issuer_signature">verify_issuer_signature</a>(money_order_descriptor: <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrderDescriptor</a>,
                            issuer_signature: vector&lt;u8&gt;,
) <b>acquires</b> <a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a> {
    <b>let</b> orders = borrow_global&lt;<a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a>&gt;(
        money_order_descriptor.issuer_address);

    <b>let</b> issuer_message = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>();
    <a href="Vector.md#0x1_Vector_append">Vector::append</a>(&<b>mut</b> issuer_message, b"@@$$LIBRA_MONEY_ORDER_ISSUE$$@@");
    <a href="Vector.md#0x1_Vector_append">Vector::append</a>(&<b>mut</b> issuer_message, <a href="LCS.md#0x1_LCS_to_bytes">LCS::to_bytes</a>(&money_order_descriptor));
    <b>assert</b>(<a href="Signature.md#0x1_Signature_ed25519_verify">Signature::ed25519_verify</a>(issuer_signature,
                                     *&orders.public_key,
                                     issuer_message),
           8002);
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_verify_user_signature"></a>

## Function `verify_user_signature`



<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_verify_user_signature">verify_user_signature</a>(receiver: &signer, money_order_descriptor: <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrder::MoneyOrderDescriptor</a>, user_signature: vector&lt;u8&gt;, domain_authenticator: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_verify_user_signature">verify_user_signature</a>(receiver: &signer,
                          money_order_descriptor: <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrderDescriptor</a>,
                          user_signature: vector&lt;u8&gt;,
                          domain_authenticator: vector&lt;u8&gt;,
) {
    <b>let</b> message = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>();
    <a href="Vector.md#0x1_Vector_append">Vector::append</a>(&<b>mut</b> message, domain_authenticator);
    <a href="Vector.md#0x1_Vector_append">Vector::append</a>(&<b>mut</b> message, <a href="LCS.md#0x1_LCS_to_bytes">LCS::to_bytes</a>(&<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(receiver)));
    <a href="Vector.md#0x1_Vector_append">Vector::append</a>(&<b>mut</b> message, <a href="LCS.md#0x1_LCS_to_bytes">LCS::to_bytes</a>(&money_order_descriptor));
    <b>assert</b>(<a href="Signature.md#0x1_Signature_ed25519_verify">Signature::ed25519_verify</a>(user_signature,
                                     *&money_order_descriptor.user_public_key,
                                     *&message),
           8002);
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_test_and_set_order_status"></a>

## Function `test_and_set_order_status`



<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_test_and_set_order_status">test_and_set_order_status</a>(status_array: &<b>mut</b> vector&lt;u8&gt;, order_index: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_test_and_set_order_status">test_and_set_order_status</a>(status_array: &<b>mut</b> vector&lt;u8&gt;,
                              order_index: u64,
): bool {
    <b>let</b> byte_index = order_index / 8;
    <b>let</b> bit_index = order_index % 8;
    <b>let</b> bitmask = (1 &lt;&lt; (bit_index <b>as</b> u8));
    <b>let</b> target_byte = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(status_array, byte_index);

    <b>let</b> test_status: bool = (*target_byte & bitmask) == bitmask;
    *target_byte = *target_byte | bitmask;
    test_status
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_cancel_order_impl"></a>

## Function `cancel_order_impl`



<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_cancel_order_impl">cancel_order_impl</a>(issuer_address: address, batch_index: u64, order_index: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_cancel_order_impl">cancel_order_impl</a>(issuer_address: address,
                      batch_index: u64,
                      order_index: u64,
): bool <b>acquires</b> <a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a> {
    <b>let</b> orders = borrow_global_mut&lt;<a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a>&gt;(issuer_address);
    <b>let</b> order_batch = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> orders.batches, batch_index);

    <b>let</b> was_expired = <a href="#0x1_MoneyOrder_time_expired">time_expired</a>(order_batch.expiration_time);

    // The money order was canceled now <b>if</b> it wasn't expired, and <b>if</b> the
    // status bit wasn't 1 (e.g. already canceled or redeemed). Note: If
    // expired, don't set the bit since the order_status array may be cleared.
    <b>let</b> canceled_now = !(was_expired ||
                         <a href="#0x1_MoneyOrder_test_and_set_order_status">test_and_set_order_status</a>(&<b>mut</b> order_batch.order_status,
                                                   order_index));

    <b>if</b> (canceled_now) {
        // Log a canceled event.
        <a href="Event.md#0x1_Event_emit_event">Event::emit_event</a>&lt;<a href="#0x1_MoneyOrder_CanceledMoneyOrderEvent">CanceledMoneyOrderEvent</a>&gt;(
            &<b>mut</b> orders.canceled_events,
            <a href="#0x1_MoneyOrder_CanceledMoneyOrderEvent">CanceledMoneyOrderEvent</a> {
                batch_index: batch_index,
                order_index: order_index,
            }
        );
    };

    canceled_now
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_issuer_cancel_money_order"></a>

## Function `issuer_cancel_money_order`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_issuer_cancel_money_order">issuer_cancel_money_order</a>(issuer: &signer, batch_index: u64, order_index: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_issuer_cancel_money_order">issuer_cancel_money_order</a>(issuer: &signer,
                                     batch_index: u64,
                                     order_index: u64,
): bool <b>acquires</b> <a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a> {
    <a href="#0x1_MoneyOrder_cancel_order_impl">cancel_order_impl</a>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer),
                      batch_index,
                      order_index)
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_redeem_money_order"></a>

## Function `redeem_money_order`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_redeem_money_order">redeem_money_order</a>(receiver: &signer, money_order_descriptor: <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrder::MoneyOrderDescriptor</a>, issuer_signature: vector&lt;u8&gt;, user_signature: vector&lt;u8&gt;): <a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrder::MoneyOrderCoin</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_redeem_money_order">redeem_money_order</a>(receiver: &signer,
                              money_order_descriptor: <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrderDescriptor</a>,
                              issuer_signature: vector&lt;u8&gt;,
                              user_signature: vector&lt;u8&gt;,
): <a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrderCoin</a> <b>acquires</b> <a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a> {
    <a href="#0x1_MoneyOrder_verify_user_signature">verify_user_signature</a>(receiver,
                          *&money_order_descriptor,
                          user_signature,
                          b"@@$$LIBRA_MONEY_ORDER_REDEEM$$@@");
    <a href="#0x1_MoneyOrder_verify_issuer_signature">verify_issuer_signature</a>(*&money_order_descriptor, issuer_signature);

    <b>let</b> issuer_address = money_order_descriptor.issuer_address;
    <b>let</b> orders = borrow_global_mut&lt;<a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a>&gt;(issuer_address);
    <b>let</b> order_batch = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> orders.batches,
                                         money_order_descriptor.batch_index);

    // Verify that money order is not expired.
    <b>assert</b>(!<a href="#0x1_MoneyOrder_time_expired">time_expired</a>(order_batch.expiration_time), 8001);

    // Update the status bit, verify that it was 0.
    <b>assert</b>(!<a href="#0x1_MoneyOrder_test_and_set_order_status">test_and_set_order_status</a>(&<b>mut</b> order_batch.order_status,
                                     money_order_descriptor.order_index), 8003);

    // Actually withdraw the coins from issuer's account.
    <b>let</b> issuer_coin_value = &<b>mut</b> orders.balance.amount;
    // orders.balance.issuer == money_order_descriptor.issuer, issuer's MOCoin.
    <b>assert</b>(*issuer_coin_value &gt;= money_order_descriptor.amount, 8004);
    *issuer_coin_value = *issuer_coin_value - money_order_descriptor.amount;

    // Log a redeemed event.
    <a href="Event.md#0x1_Event_emit_event">Event::emit_event</a>&lt;<a href="#0x1_MoneyOrder_RedeemedMoneyOrderEvent">RedeemedMoneyOrderEvent</a>&gt;(
        &<b>mut</b> orders.redeemed_events,
        <a href="#0x1_MoneyOrder_RedeemedMoneyOrderEvent">RedeemedMoneyOrderEvent</a> {
            amount: money_order_descriptor.amount,
            batch_index: money_order_descriptor.batch_index,
            order_index: money_order_descriptor.order_index,
        }
    );

    <a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrderCoin</a> {
        amount: money_order_descriptor.amount,
        issuer_address: issuer_address,
    }
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_index_of_coin"></a>

## Function `index_of_coin`



<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_index_of_coin">index_of_coin</a>(coins_vector: &vector&lt;<a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrder::MoneyOrderCoin</a>&gt;, issuer_address: address): (bool, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_index_of_coin">index_of_coin</a>(coins_vector: &vector&lt;<a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrderCoin</a>&gt;,
                  issuer_address: address,
): (bool, u64) {
    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="Vector.md#0x1_Vector_length">Vector::length</a>(coins_vector)) {
        <b>let</b> coin = <a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(coins_vector, i);
        <b>if</b> (coin.issuer_address == issuer_address) <b>return</b> (<b>true</b>, i);
        i = i + 1;
    };
    (<b>false</b>, 0)
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_money_order_coin_balance"></a>

## Function `money_order_coin_balance`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_money_order_coin_balance">money_order_coin_balance</a>(sender: &signer, issuer_address: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_money_order_coin_balance">money_order_coin_balance</a>(sender: &signer,
                                    issuer_address: address,
) : u64 <b>acquires</b> <a href="#0x1_MoneyOrder_MoneyOrderCoinVector">MoneyOrderCoinVector</a> {
    <b>let</b> sender_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);

    <b>if</b> (!exists&lt;<a href="#0x1_MoneyOrder_MoneyOrderCoinVector">MoneyOrderCoinVector</a>&gt;(sender_address)) <b>return</b> 0;

    <b>let</b> coins_vec = borrow_global&lt;<a href="#0x1_MoneyOrder_MoneyOrderCoinVector">MoneyOrderCoinVector</a>&gt;(sender_address);
    <b>let</b> (found, coin_index) = <a href="#0x1_MoneyOrder_index_of_coin">index_of_coin</a>(&coins_vec.coins,
                                            issuer_address);
    <b>if</b> (!found) <b>return</b> 0;

    <b>let</b> target_coin = <a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&coins_vec.coins, coin_index);
    target_coin.amount
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_init_coins_money_order"></a>

## Function `init_coins_money_order`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_init_coins_money_order">init_coins_money_order</a>(receiver: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_init_coins_money_order">init_coins_money_order</a>(receiver: &signer)
     {

    <b>let</b> receiver_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(receiver);

    // Get receiver's storage of <a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrderCoin</a>, currently a <a href="Vector.md#0x1_Vector">Vector</a>. Publish an
    // empty <a href="Vector.md#0x1_Vector">Vector</a>&lt;<a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrderCoin</a>&gt; <b>if</b> none exists at receiver's account yet.
    // TODO: Switch <b>to</b> a Map when that exists <b>to</b> merge coins based on address.
    <b>if</b> (!exists&lt;<a href="#0x1_MoneyOrder_MoneyOrderCoinVector">MoneyOrderCoinVector</a>&gt;(receiver_address)) {
        move_to(receiver, <a href="#0x1_MoneyOrder_MoneyOrderCoinVector">MoneyOrderCoinVector</a> {
            coins: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
        });
    };

}
</code></pre>



</details>

<a name="0x1_MoneyOrder_deposit_money_order"></a>

## Function `deposit_money_order`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_deposit_money_order">deposit_money_order</a>(receiver: &signer, money_order_descriptor: <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrder::MoneyOrderDescriptor</a>, issuer_signature: vector&lt;u8&gt;, user_signature: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_deposit_money_order">deposit_money_order</a>(receiver: &signer,
                               money_order_descriptor: <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrderDescriptor</a>,
                               issuer_signature: vector&lt;u8&gt;,
                               user_signature: vector&lt;u8&gt;,
) <b>acquires</b> <a href="#0x1_MoneyOrder_MoneyOrderCoinVector">MoneyOrderCoinVector</a>, <a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a> {
    <b>let</b> <a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrderCoin</a> { amount, issuer_address } =
        <a href="#0x1_MoneyOrder_redeem_money_order">redeem_money_order</a>(receiver,
                           money_order_descriptor,
                           issuer_signature,
                           user_signature);

    <b>let</b> receiver_address = <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(receiver);

    // Get receiver's storage of <a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrderCoin</a>, currently a <a href="Vector.md#0x1_Vector">Vector</a>. Publish an
    // empty <a href="Vector.md#0x1_Vector">Vector</a>&lt;<a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrderCoin</a>&gt; <b>if</b> none exists at receiver's account yet.
    // TODO: Switch <b>to</b> a Map when that exists <b>to</b> merge coins based on address.
    <b>if</b> (!exists&lt;<a href="#0x1_MoneyOrder_MoneyOrderCoinVector">MoneyOrderCoinVector</a>&gt;(receiver_address)) {
        move_to(receiver, <a href="#0x1_MoneyOrder_MoneyOrderCoinVector">MoneyOrderCoinVector</a> {
            coins: <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>(),
        });
    };
    <b>let</b> receiver_vec =
        borrow_global_mut&lt;<a href="#0x1_MoneyOrder_MoneyOrderCoinVector">MoneyOrderCoinVector</a>&gt;(receiver_address);

    <b>let</b> (found, coin_index) = <a href="#0x1_MoneyOrder_index_of_coin">index_of_coin</a>(&receiver_vec.coins,
                                            issuer_address);
    <b>if</b> (!found)
    {
        coin_index = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&receiver_vec.coins);
        <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> receiver_vec.coins,
                          <a href="#0x1_MoneyOrder_mint_money_order_coin">mint_money_order_coin</a>(0, issuer_address));
    };

    // Actually increment the <a href="#0x1_MoneyOrder_MoneyOrderCoin">MoneyOrderCoin</a>'s value (issued by issuer).
    <b>let</b> target_coin = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> receiver_vec.coins,
                                         coin_index);
    <b>let</b> target_coin_value = &<b>mut</b> target_coin.amount;
    *target_coin_value = *target_coin_value + amount;
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_cancel_money_order"></a>

## Function `cancel_money_order`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_cancel_money_order">cancel_money_order</a>(receiver: &signer, money_order_descriptor: <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrder::MoneyOrderDescriptor</a>, issuer_signature: vector&lt;u8&gt;, user_signature: vector&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_cancel_money_order">cancel_money_order</a>(receiver: &signer,
                              money_order_descriptor: <a href="#0x1_MoneyOrder_MoneyOrderDescriptor">MoneyOrderDescriptor</a>,
                              issuer_signature: vector&lt;u8&gt;,
                              user_signature: vector&lt;u8&gt;,
): bool <b>acquires</b> <a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a> {
    <a href="#0x1_MoneyOrder_verify_user_signature">verify_user_signature</a>(receiver,
                          *&money_order_descriptor,
                          user_signature,
                          b"@@$$LIBRA_MONEY_ORDER_CANCEL$$@@");
    <a href="#0x1_MoneyOrder_verify_issuer_signature">verify_issuer_signature</a>(*&money_order_descriptor, issuer_signature);

    <a href="#0x1_MoneyOrder_cancel_order_impl">cancel_order_impl</a>(money_order_descriptor.issuer_address,
                      money_order_descriptor.batch_index,
                      money_order_descriptor.order_index)
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_clear_vector"></a>

## Function `clear_vector`



<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_clear_vector">clear_vector</a>(v: &<b>mut</b> vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_clear_vector">clear_vector</a>(v: &<b>mut</b> vector&lt;u8&gt;,) {
    <b>let</b> length = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(v);

    <b>let</b> i = 0;
    <b>while</b> (i &lt; length) {
        <a href="Vector.md#0x1_Vector_pop_back">Vector::pop_back</a>(v);
        i = i + 1;
    };
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_clear_statuses_if_expired"></a>

## Function `clear_statuses_if_expired`



<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_clear_statuses_if_expired">clear_statuses_if_expired</a>(status_array: &<b>mut</b> vector&lt;u8&gt;, expiration_time: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="#0x1_MoneyOrder_clear_statuses_if_expired">clear_statuses_if_expired</a>(status_array: &<b>mut</b> vector&lt;u8&gt;,
                              expiration_time: u64,
): bool {
    <b>let</b> expired = <a href="#0x1_MoneyOrder_time_expired">time_expired</a>(expiration_time);

    <b>let</b> was_empty = <a href="Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(status_array);
    <b>if</b> (expired) {
        <a href="#0x1_MoneyOrder_clear_vector">clear_vector</a>(status_array);
    };

    expired && !was_empty
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_compress_expired_batch"></a>

## Function `compress_expired_batch`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_compress_expired_batch">compress_expired_batch</a>(issuer: &signer, batch_index: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_compress_expired_batch">compress_expired_batch</a>(issuer: &signer,
                                  batch_index: u64,
): bool <b>acquires</b> <a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a> {
    <b>let</b> orders = borrow_global_mut&lt;<a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer));
    <b>let</b> batch = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> orders.batches, batch_index);

    <a href="#0x1_MoneyOrder_clear_statuses_if_expired">clear_statuses_if_expired</a>(&<b>mut</b> batch.order_status,
                              batch.expiration_time)
}
</code></pre>



</details>

<a name="0x1_MoneyOrder_compress_expired_batches"></a>

## Function `compress_expired_batches`



<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_compress_expired_batches">compress_expired_batches</a>(issuer: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="#0x1_MoneyOrder_compress_expired_batches">compress_expired_batches</a>(issuer: &signer
) <b>acquires</b> <a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a> {
    <b>let</b> orders = borrow_global_mut&lt;<a href="#0x1_MoneyOrder_MoneyOrders">MoneyOrders</a>&gt;(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(issuer));

    <b>let</b> i = 0;
    <b>while</b> (i &lt; <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&orders.batches)) {
        <b>let</b> batch = <a href="Vector.md#0x1_Vector_borrow_mut">Vector::borrow_mut</a>(&<b>mut</b> orders.batches, i);
        <a href="#0x1_MoneyOrder_clear_statuses_if_expired">clear_statuses_if_expired</a>(&<b>mut</b> batch.order_status,
                                  batch.expiration_time);
        i = i + 1;
    };
}
</code></pre>



</details>
