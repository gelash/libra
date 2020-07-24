// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::{AccountData},
    common_transactions::{
        initialize_money_orders_txn,
    },
    executor::FakeExecutor,
};

use libra_types::{
    transaction::TransactionStatus,
    vm_status::{StatusCode, VMStatus},
};

#[test]
fn initialize_money_orders() {
    let mut executor = FakeExecutor::from_genesis_file();
    let issuer_account = AccountData::new(1000, 10);
    executor.add_account_data(&issuer_account);
    
    executor.new_block();
    let txn = initialize_money_orders_txn(
        &issuer_account.account(),
        [
            0xd7, 0x5a, 0x98, 0x01, 0x82, 0xb1, 0x0a, 0xb7, 0xd5, 0x4b, 0xfe, 0xd3, 0xc9, 0x64,
            0x07, 0x3a, 0x0e, 0xe1, 0x72, 0xf3, 0xda, 0xa6, 0x23, 0x25, 0xaf, 0x02, 0x1a, 0x68,
            0xf7, 0x07, 0x51, 0x1a,
        ].to_vec(),
        1000000,
        10,
    );
    let output = executor.execute_and_apply(txn);

    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    );
}

