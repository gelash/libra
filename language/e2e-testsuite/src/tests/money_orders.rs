// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use compiled_stdlib::transaction_scripts::StdlibScript;
use language_e2e_tests::{
    account::{Account,
              AccountData,
              AccountRoleSpecifier,
              lbr_currency_code},
    executor::FakeExecutor,
    keygen::KeyGen,
};
use libra_types::{
    account_config::{CanceledMoneyOrderEvent,
                     IssuedMoneyOrderEvent,
                     RedeemedMoneyOrderEvent,},
    transaction::TransactionStatus,
    vm_status::{KeptVMStatus},
    transaction::{Script,
                  SignedTransaction,
                  TransactionArgument,
                  TransactionOutput},
};
use std::convert::TryFrom;

// Returns a transaction to publish money orders.
fn publish_money_orders_txn(
    sender: &Account,
    public_key: Vec<u8>,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::U8Vector(public_key));

    sender
        .transaction()
        .script(Script::new(
            StdlibScript::PublishMoneyOrders
                .compiled_bytes()
                .into_vec(),
            vec![],
            args,
        ))
        .sequence_number(seq_num)
        .sign()
}

// Returns a transaction to set up money order asset holder.
fn set_up_money_order_asset_holder_txn(
    sender: &Account,
    amount: u64,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    // Asset type ID is hardcoded to 0: IssuerToken
    args.push(TransactionArgument::U8(0));
    // Asset specialization ID is hardcoded to 0: DefaultToken
    args.push(TransactionArgument::U8(0));
    args.push(TransactionArgument::U64(amount));

    sender
        .transaction()
        .script(Script::new(
            StdlibScript::TopUpMoneyOrderAssetHolder
                .compiled_bytes()
                .into_vec(),
            vec![],
            args,
        ))
        .sequence_number(seq_num)
        .sign()
}

// Returns a transaction to issue a money order batch of 100,
// with duration 1 hr.
fn issue_money_order_batch_txn(
    sender: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::U64(100));
    args.push(TransactionArgument::U64(3600000000));
    args.push(TransactionArgument::U64(0));

    sender
        .transaction()
        .script(Script::new(
            StdlibScript::IssueMoneyOrderBatch
                .compiled_bytes()
                .into_vec(),
            vec![],
            args,
        ))
        .sequence_number(seq_num)
        .sign()
}

fn deposit_money_order_txn(
    receiver: &Account,
    amount: u64,
    issuer: &Account,
    batch_index: u64,
    order_index: u64,
    user_public_key: Vec<u8>,
    issuer_signature: Vec<u8>,
    user_signature: Vec<u8>,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::U64(amount));
    // Asset type ID is hardcoded to 0: IssuerToken
    args.push(TransactionArgument::U8(0));
    // Asset specialization ID is hardcoded to 0: DefaultToken
    args.push(TransactionArgument::U8(0));
    args.push(TransactionArgument::Address(*issuer.address()));
    args.push(TransactionArgument::U64(batch_index));
    args.push(TransactionArgument::U64(order_index));
    args.push(TransactionArgument::U8Vector(user_public_key));
    args.push(TransactionArgument::U8Vector(issuer_signature));
    args.push(TransactionArgument::U8Vector(user_signature));

    receiver
        .transaction()
        .script(Script::new(
            StdlibScript::DepositMoneyOrder
                .compiled_bytes()
                .into_vec(),
            vec![],
            args,
        ))
        .sequence_number(seq_num)
        .sign()
}

fn cancel_money_order_txn(
    receiver: &Account,
    amount: u64,
    issuer: &Account,
    batch_index: u64,
    order_index: u64,
    user_public_key: Vec<u8>,
    issuer_signature: Vec<u8>,
    user_signature: Vec<u8>,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::U64(amount));
    // Asset type ID is hardcoded to 0: IssuerToken
    args.push(TransactionArgument::U8(0));
    // Asset specialization ID is hardcoded to 0: DefaultToken
    args.push(TransactionArgument::U8(0));
    args.push(TransactionArgument::Address(*issuer.address()));
    args.push(TransactionArgument::U64(batch_index));
    args.push(TransactionArgument::U64(order_index));
    args.push(TransactionArgument::U8Vector(user_public_key));
    args.push(TransactionArgument::U8Vector(issuer_signature));
    args.push(TransactionArgument::U8Vector(user_signature));

    receiver
        .transaction()
        .script(Script::new(
            StdlibScript::CancelMoneyOrder
                .compiled_bytes()
                .into_vec(),
            vec![],
            args,
        ))
        .sequence_number(seq_num)
        .sign()
}

fn assert_aborted_with(output: TransactionOutput, error_code: u64) {
    if let Ok(KeptVMStatus::MoveAbort(_, code)) = output.status().status() {
        assert_eq!(code, error_code); 
    } else {
        panic!("expected MoveAbort")
    }
}

#[test]
fn money_orders() {
    let mut executor = FakeExecutor::from_genesis_file();

    // Add issuer's account
    let (privkey, pubkey) = KeyGen::from_seed([9u8; 32]).generate_keypair();
    let issuer_account =
        AccountData::with_keypair(privkey,
                                  pubkey,
                                  1000,
                                  lbr_currency_code(),
                                  10,
                                  AccountRoleSpecifier::ParentVASP,);
    executor.add_account_data(&issuer_account);
    // println!("{}", issuer_account.address());
    // Addr is 5455a8193f1dfc1b113ecc54d067afe1

    // Add receiver's account    
    let (privkey, pubkey) = KeyGen::from_seed([7u8; 32]).generate_keypair();
    let receiver_account = 
        AccountData::with_keypair(privkey,
                                  pubkey,
                                  1000,
                                  lbr_currency_code(),
                                  10,
                                  AccountRoleSpecifier::ParentVASP,);
    executor.add_account_data(&receiver_account);
    // println!("{}", receiver_account.address());
    // Addr is ffccb556fc111b099569ce5d4af70906

    executor.new_block();

    // Publishing money orders resource and asset holder with initial balance.
    let txn = publish_money_orders_txn(
        &issuer_account.account(),
        [
            0x17, 0x6e, 0xb4, 0xe0, 0x35, 0xea, 0xdc, 0x70, 0x80, 0xf0, 0x50, 0xc8, 0x82, 0xbf,
            0xcf, 0xb4, 0x61, 0xa0, 0x12, 0xc7, 0x6e, 0xbc, 0xf1, 0x07, 0xf3, 0x9c, 0x9b, 0xb0,
            0x1b, 0x46, 0xff, 0xc5,
        ].to_vec(),
        10,
    );
    let output = executor.execute_and_apply(txn);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed),
    );
    let txn = set_up_money_order_asset_holder_txn(
        &issuer_account.account(),
        1000000,
        11,
    );
    let output = executor.execute_and_apply(txn);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed),
    );

    // Issue a batch of money orders.
    let txn = issue_money_order_batch_txn(
        &issuer_account.account(),
        12,
    );
    let output = executor.execute_and_apply(txn);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed),
    );
    let issued_events: Vec<_> = output
        .events()
        .iter()
        .filter_map(|event| IssuedMoneyOrderEvent::try_from(event).ok())
        .collect();
    assert_eq!(issued_events.len(), 1);
    let issued_event = &issued_events[0];
    assert_eq!(issued_event.batch_index(), 0);
    assert_eq!(issued_event.num_orders(), 100);

    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::U64(0));
    args.push(TransactionArgument::U64(2));
    let txn = issuer_account.account()
        .transaction()
        .script(Script::new(
            StdlibScript::IssuerCancelMoneyOrder
                .compiled_bytes()
                .into_vec(),
            vec![],
            args,
        ))
        .sequence_number(13)
        .sign();
    let output = executor.execute_and_apply(txn);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed),
    );
    let issued_events: Vec<_> = output
        .events()
        .iter()
        .filter_map(|event| CanceledMoneyOrderEvent::try_from(event).ok())
        .collect();
    assert_eq!(issued_events.len(), 1);
    let issued_event = &issued_events[0];
    assert_eq!(issued_event.batch_index(), 0);
    assert_eq!(issued_event.order_index(), 2);

    let txn = deposit_money_order_txn(
        &receiver_account.account(),
        5,
        &issuer_account.account(),
        0,
        3,
        [
            0xb5, 0x22, 0xe7, 0xbb, 0x6b, 0x33, 0xf9, 0xba, 0x0f, 0x5c, 0xc6, 0xbd, 0x0d, 0x1a,
            0xba, 0x16, 0x0a, 0xf5, 0xd6, 0xce, 0x3d, 0xf0, 0xbd, 0xdf, 0xc6, 0xf9, 0x74, 0x7d,
            0xa8, 0x0c, 0x72, 0xbb,
        ].to_vec(),
        [
            0x19, 0x0d, 0x01, 0x81, 0xa6, 0xc3, 0x73, 0x5c, 0xd6, 0xcd, 0xe8, 0x53, 0xbd, 0x09,
            0x77, 0xc2, 0xd6, 0xa1, 0xb8, 0xa5, 0xaa, 0x6d, 0xf0, 0xdf, 0xa2, 0x92, 0xac, 0x03,
            0x63, 0x3f, 0x5e, 0xed, 0xee, 0xe3, 0xee, 0x3b, 0x0b, 0x10, 0x77, 0xb7, 0x16, 0x5c,
            0xc5, 0xbb, 0x24, 0x7b, 0x05, 0x95, 0x11, 0x0b, 0xe7, 0x97, 0xd9, 0x64, 0xb9, 0x63,
            0x90, 0x30, 0x6f, 0x01, 0xab, 0x43, 0x50, 0x05,
        ].to_vec(),
        [
            0x18, 0xbc, 0xab, 0xd2, 0x7c, 0x6b, 0xb3, 0x78, 0x99, 0xc2, 0xf7, 0xc0, 0xf6, 0xef,
            0x96, 0xd3, 0x1a, 0x40, 0x00, 0xeb, 0xa4, 0x97, 0x71, 0xc1, 0xac, 0x3f, 0x15, 0xa2,
            0x8c, 0x1f, 0xc4, 0xc9, 0xea, 0x59, 0xa0, 0x8f, 0x90, 0x19, 0x56, 0x5f, 0x24, 0xf0,
            0x77, 0x0f, 0x99, 0x28, 0x7f, 0x75, 0x15, 0x03, 0xd5, 0x78, 0xf8, 0xba, 0x89, 0xd5,
            0x92, 0x4c, 0xe3, 0x36, 0xe0, 0xb4, 0xf6, 0x0b,
        ].to_vec(),
        10,
    );
    let output = executor.execute_and_apply(txn);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed),
    );
    let issued_events: Vec<_> = output
        .events()
        .iter()
        .filter_map(|event| RedeemedMoneyOrderEvent::try_from(event).ok())
        .collect();
    assert_eq!(issued_events.len(), 1);
    let issued_event = &issued_events[0];
    assert_eq!(issued_event.batch_index(), 0);
    assert_eq!(issued_event.order_index(), 3);
    assert_eq!(issued_event.amount(), 5);

    let txn = cancel_money_order_txn(
        &receiver_account.account(),
        5,
        &issuer_account.account(),
        0,
        4,
        [
            0xb6, 0xfa, 0xfd, 0x19, 0x9e, 0x01, 0xb2, 0x8c, 0x8c, 0x86, 0xb3, 0xcd, 0xd5, 0x6d,
            0x7b, 0x07, 0x00, 0x2a, 0x1b, 0x6d, 0x4a, 0xb1, 0x65, 0x27, 0x0c, 0x24, 0xd4, 0x6c,
            0x18, 0x13, 0xa8, 0x36,
        ].to_vec(),
        [
            0x6a, 0x16, 0x7f, 0xdd, 0xd1, 0xcd, 0x39, 0x64, 0x07, 0x6f, 0x46, 0xc8, 0x2b, 0x4c,
            0x1e, 0x19, 0x84, 0x07, 0x1e, 0x70, 0x1a, 0x72, 0x5f, 0x8f, 0xbf, 0x04, 0x6e, 0xdd,
            0x98, 0x73, 0x2b, 0xdc, 0x21, 0x79, 0x70, 0x69, 0x78, 0x9a, 0x91, 0x1d, 0x3c, 0x0d,
            0x7a, 0xf1, 0x4a, 0x7e, 0x7f, 0xa4, 0x3a, 0x5e, 0xf4, 0x08, 0x32, 0x4f, 0xf0, 0x8e,
            0x1a, 0x34, 0xc4, 0xbc, 0x1b, 0x4b, 0x97, 0x00,
        ].to_vec(),
        [
            0x07, 0xf1, 0x36, 0x72, 0x7e, 0x63, 0xdd, 0x1a, 0x45, 0x80, 0xd6, 0x6b, 0xf2, 0xca,
            0xd8, 0xa1, 0x94, 0x5e, 0x17, 0xcf, 0x82, 0x08, 0xf9, 0x33, 0xd6, 0x12, 0x1e, 0x7e,
            0xa7, 0x87, 0xf7, 0xc1, 0xe4, 0x8f, 0x94, 0x27, 0xd0, 0xac, 0xb0, 0x6d, 0x91, 0x45,
            0x35, 0xb8, 0x91, 0x44, 0xb6, 0x8b, 0xa8, 0xd3, 0xb2, 0x5e, 0xe2, 0x37, 0xd6, 0xf9,
            0x40, 0x47, 0x36, 0xcb, 0x30, 0x26, 0x16, 0x0b,
        ].to_vec(),
        11,
    );
    let output = executor.execute_and_apply(txn);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed),
    );
        let issued_events: Vec<_> = output
        .events()
        .iter()
        .filter_map(|event| CanceledMoneyOrderEvent::try_from(event).ok())
        .collect();
    assert_eq!(issued_events.len(), 1);
    let issued_event = &issued_events[0];
    assert_eq!(issued_event.batch_index(), 0);
    assert_eq!(issued_event.order_index(), 4);

    // Wrong user signature
    let txn = cancel_money_order_txn(
        &receiver_account.account(),
        5,
        &issuer_account.account(),
        1,
        7,
        [
            0xfe, 0x3e, 0x4f, 0x8d, 0x26, 0x06, 0xab, 0x21, 0xae, 0x9c, 0x8b, 0xbc, 0xe1, 0x08,
            0x4b, 0x1d, 0x4f, 0x12, 0x02, 0x3c, 0xd7, 0x4a, 0xc6, 0x2e, 0xfc, 0x35, 0xd2, 0x8a,
            0xd1, 0xbf, 0xc8, 0x44,
        ].to_vec(),
        [
            0xb1, 0x89, 0x19, 0x29, 0xd9, 0x6b, 0x5d, 0x8a, 0x55, 0xd3, 0x24, 0x8c, 0x67, 0xd9,
            0xc7, 0x20, 0x62, 0x0f, 0xd8, 0x0e, 0x79, 0xb3, 0x2b, 0xfb, 0x9d, 0xb6, 0x77, 0x2f,
            0xd4, 0xda, 0xdb, 0xac, 0x1a, 0xdf, 0xb0, 0x40, 0xb5, 0x69, 0xd7, 0xb8, 0x02, 0x8f,
            0x7f, 0xc2, 0x52, 0x15, 0x74, 0x71, 0x83, 0xf1, 0x39, 0x85, 0xab, 0xe2, 0x2c, 0xdd,
            0x0c, 0x5b, 0x50, 0x5d, 0x5a, 0xe2, 0xee, 0x0d,
        ].to_vec(),
        [
            0x85, 0x98, 0x2a, 0xb9, 0xf2, 0xc0, 0x7d, 0x73, 0x9a, 0x1a, 0xd7, 0x0a, 0xe4, 0x6a,
            0x4c, 0x93, 0x62, 0xdf, 0xb2, 0x26, 0xb9, 0x27, 0x91, 0x81, 0xe2, 0xfa, 0xac, 0xce,
            0x19, 0xaa, 0xd2, 0xe4, 0xbb, 0x8b, 0x9a, 0x2d, 0x41, 0x10, 0x63, 0xf0, 0x95, 0x1a,
            0x8f, 0x8e, 0xf6, 0xd4, 0x4c, 0x83, 0x3b, 0x49, 0x28, 0x63, 0x1d, 0x9d, 0x5e, 0xf2,
            0x73, 0x32, 0xf8, 0x70, 0x7d, 0xe7, 0xb9, 0x0c,
        ].to_vec(),
        12,
    );
    let output = executor.execute_transaction(txn);
    assert_aborted_with(output, 1031);

    // Already (issuer) canceled.
    let txn = deposit_money_order_txn(
        &receiver_account.account(),
        5,
        &issuer_account.account(),
        0,
        2,
        [
            0xa0, 0x8d, 0x1b, 0xd0, 0x1c, 0xfb, 0xe7, 0x04, 0xf3, 0xf8, 0x65, 0x51, 0xad, 0xe8,
            0x45, 0x12, 0xd7, 0x60, 0xb9, 0x06, 0x17, 0xae, 0x9a, 0xcd, 0xb0, 0x9a, 0x9a, 0xd1,
            0x1a, 0xf0, 0x4c, 0x59,
        ].to_vec(),
        [
            0x04, 0xb5, 0x83, 0x12, 0x01, 0x26, 0x12, 0x6b, 0x22, 0x55, 0x6a, 0xf6, 0x82, 0x94,
            0x61, 0x96, 0x48, 0x54, 0xb3, 0x42, 0x3b, 0xe1, 0x48, 0xd7, 0xf4, 0xff, 0xfe, 0x8e,
            0x5e, 0x66, 0xe1, 0x5a, 0xcd, 0x7f, 0x7f, 0xc5, 0x12, 0x32, 0xbd, 0x04, 0x81, 0xd2,
            0x78, 0xdd, 0x77, 0xce, 0x59, 0x00, 0xef, 0xb6, 0xc7, 0xbd, 0x11, 0x91, 0x99, 0x55,
            0x0f, 0xa3, 0xb0, 0xee, 0x57, 0xf7, 0xc2, 0x09,
        ].to_vec(),
        [
            0x58, 0xad, 0xe2, 0xc6, 0xd8, 0x02, 0x6b, 0xc8, 0x4c, 0x50, 0x42, 0xfb, 0x53, 0x27,
            0xaf, 0xd5, 0xdb, 0x1f, 0x98, 0x27, 0xd8, 0x3f, 0x47, 0x3e, 0xc2, 0xe9, 0xa7, 0x6f,
            0xcd, 0x3c, 0xa1, 0xea, 0xff, 0xd6, 0x13, 0xa0, 0x17, 0x5b, 0x42, 0x3f, 0x45, 0xf6,
            0xdc, 0xb7, 0x0b, 0x0c, 0x99, 0x44, 0x58, 0x1c, 0x24, 0x79, 0xd5, 0xe8, 0x2f, 0x6b,
            0x03, 0xea, 0x36, 0xff, 0x71, 0xe3, 0x00, 0x0f,
        ].to_vec(),
        12,
    );
    let output = executor.execute_transaction(txn);
    assert_aborted_with(output, 1537);

    // Cancel deposited - does nothing, but doesn't abort.
    // TODO: check the cancel event that cancel didn't do anything.
    let txn = cancel_money_order_txn(
        &receiver_account.account(),
        5,
        &issuer_account.account(),
        0,
        3,
        [
            0xb2, 0xfa, 0x93, 0xb2, 0x59, 0xbf, 0x17, 0x5d, 0x5e, 0xa0, 0x47, 0x85, 0xcb, 0xac,
            0x8a, 0xa2, 0xbe, 0x74, 0xd7, 0x90, 0x61, 0xb4, 0x41, 0x8e, 0x32, 0x00, 0x75, 0x17,
            0x3a, 0x19, 0x2d, 0x31,
        ].to_vec(),
        [
            0x2e, 0xb7, 0xd7, 0x7f, 0x6d, 0xd3, 0x90, 0xbb, 0xc2, 0xdd, 0x7b, 0xeb, 0x47, 0xee,
            0x7f, 0x16, 0x91, 0xce, 0xbe, 0xcc, 0xad, 0xa8, 0x94, 0xfc, 0xce, 0xbe, 0x7e, 0x0a,
            0x4a, 0x28, 0x12, 0xbc, 0xa9, 0x83, 0x1a, 0x1e, 0xf1, 0xca, 0xbe, 0xd6, 0xc5, 0x57,
            0x84, 0x14, 0x7c, 0x65, 0x1f, 0x0f, 0x92, 0x0f, 0xf1, 0xbf, 0xda, 0xe5, 0xf3, 0x3f,
            0xfd, 0xe9, 0xf9, 0xa8, 0x0a, 0x30, 0x61, 0x0a,
        ].to_vec(),
        [
            0xe7, 0x13, 0x1a, 0x27, 0x72, 0x33, 0xbc, 0x28, 0x80, 0xa3, 0x66, 0xd5, 0xdf, 0xe3,
            0x21, 0x7b, 0xd8, 0xab, 0x18, 0xdb, 0x31, 0x67, 0x7c, 0x47, 0xf3, 0xde, 0x99, 0xe1,
            0xef, 0x94, 0x2e, 0x68, 0xcc, 0x85, 0xce, 0x0e, 0xbe, 0xcb, 0x3c, 0xf4, 0x33, 0x11,
            0x85, 0x38, 0x9c, 0xcc, 0x80, 0x0b, 0x18, 0x89, 0x47, 0x29, 0x39, 0xdb, 0x0e, 0x3a,
            0x93, 0x7c, 0xe1, 0x5a, 0xa8, 0xfc, 0xd7, 0x0e, 
        ].to_vec(),
        12,
    );
    let output = executor.execute_and_apply(txn);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed),
    );
}

