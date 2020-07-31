// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

//! Support for encoding transactions for common situations.

use crate::account::Account;
use compiled_stdlib::transaction_scripts::StdlibScript;
use compiler::Compiler;
use libra_types::{
    account_config,
    account_config::lbr_type_tag,
    transaction::{RawTransaction, Script, SignedTransaction, TransactionArgument},
};
use move_core_types::language_storage::TypeTag;
use once_cell::sync::Lazy;

pub static CREATE_ACCOUNT_SCRIPT: Lazy<Vec<u8>> = Lazy::new(|| {
    let code = "
    import 0x1.Libra;
    import 0x1.LibraAccount;

    main<Token>(account: &signer, fresh_address: address, auth_key_prefix: vector<u8>, initial_amount: u64) {
      let with_cap: LibraAccount.WithdrawCapability;
      let name: vector<u8>;
      let url: vector<u8>;
      let pub_key: vector<u8>;
      name = h\"\";
      url = h\"\";
      pub_key = h\"b7a3c12dc0c8c748ab07525b701122b88bd78f600c76342d27f25e5f92444cde\";

      LibraAccount.create_parent_vasp_account<Token>(
        copy(account),
        copy(fresh_address),
        move(auth_key_prefix),
        move(name),
        move(url),
        move(pub_key),
        false
      );
      if (copy(initial_amount) > 0) {
         with_cap = LibraAccount.extract_withdraw_capability(copy(account));
         LibraAccount.pay_from<Token>(
           &with_cap,
           move(fresh_address),
           move(initial_amount),
           h\"\",
           h\"\"
         );
         LibraAccount.restore_withdraw_capability(move(with_cap));
      }
      return;
    }
";

    let compiler = Compiler {
        address: account_config::CORE_CODE_ADDRESS,
        extra_deps: vec![],
        ..Compiler::default()
    };
    compiler
        .into_script_blob("file_name", code)
        .expect("Failed to compile")
});

pub static EMPTY_SCRIPT: Lazy<Vec<u8>> = Lazy::new(|| {
    let code = "
    main<Token>(account: &signer) {
      return;
    }
";

    let compiler = Compiler {
        address: account_config::CORE_CODE_ADDRESS,
        extra_deps: vec![],
        ..Compiler::default()
    };
    compiler
        .into_script_blob("file_name", code)
        .expect("Failed to compile")
});

/// Returns a transaction to initialize money orders
pub fn initialize_money_orders_txn(
    sender: &Account,
    public_key: Vec<u8>,
    starting_balance: u64,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::U8Vector(public_key));
    args.push(TransactionArgument::U64(starting_balance));

    sender.create_signed_txn_with_args(
        StdlibScript::InitializeMoneyOrders.compiled_bytes().into_vec(),
        vec![],
        args,
        seq_num,
        gas_costs::TXN_RESERVED * 2,
        0,
        LBR_NAME.to_owned(),
    )
}

/// Returns a transaction to issue a money order batch of 100,
/// with duration 1 hr.
pub fn issue_money_order_batch_txn(
    sender: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::U64(100));
    args.push(TransactionArgument::U64(3600000000));

    sender.create_signed_txn_with_args(
        StdlibScript::IssueMoneyOrderBatch.compiled_bytes().into_vec(),
        vec![],
        args,
        seq_num,
        gas_costs::TXN_RESERVED * 2,
        0,
        LBR_NAME.to_owned(),
    )
}

pub fn deposit_money_order_txn(
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
    args.push(TransactionArgument::Address(*issuer.address()));
    args.push(TransactionArgument::U64(batch_index));
    args.push(TransactionArgument::U64(order_index));
    args.push(TransactionArgument::U8Vector(user_public_key));
    args.push(TransactionArgument::U8Vector(issuer_signature));
    args.push(TransactionArgument::U8Vector(user_signature));

    receiver.create_signed_txn_with_args(
        StdlibScript::DepositMoneyOrder.compiled_bytes().into_vec(),
        vec![],
        args,
        seq_num,
        gas_costs::TXN_RESERVED * 3,
        0,
        LBR_NAME.to_owned(),
    )
}

pub fn cancel_money_order_txn(
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
    args.push(TransactionArgument::Address(*issuer.address()));
    args.push(TransactionArgument::U64(batch_index));
    args.push(TransactionArgument::U64(order_index));
    args.push(TransactionArgument::U8Vector(user_public_key));
    args.push(TransactionArgument::U8Vector(issuer_signature));
    args.push(TransactionArgument::U8Vector(user_signature));

    receiver.create_signed_txn_with_args(
        StdlibScript::CancelMoneyOrder.compiled_bytes().into_vec(),
        vec![],
        args,
        seq_num,
        gas_costs::TXN_RESERVED * 3,
        0,
        LBR_NAME.to_owned(),
    )
}

/// Returns a transaction to add a new validator
pub fn add_validator_txn(
    sender: &Account,
    new_validator: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::Address(*new_validator.address()));

    sender.create_signed_txn_with_args(
        StdlibScript::AddValidator.compiled_bytes().into_vec(),
        vec![],
        args,
        seq_num,
        gas_costs::TXN_RESERVED * 2,
        0,
        LBR_NAME.to_owned(),
    )
}

/// Returns a transaction to update validators' configs and reconfigure
///   (= emit reconfiguration event and change the epoch)
pub fn reconfigure_txn(sender: &Account, seq_num: u64) -> SignedTransaction {
    sender.create_signed_txn_with_args(
        StdlibScript::Reconfigure.compiled_bytes().into_vec(),
        vec![],
        Vec::new(),
        seq_num,
        gas_costs::TXN_RESERVED * 2,
        0,
        LBR_NAME.to_owned(),
    )
}

pub fn empty_txn(
    sender: &Account,
    seq_num: u64,
    max_gas_amount: u64,
    gas_unit_price: u64,
    gas_currency_code: String,
) -> SignedTransaction {
    sender
        .transaction()
        .script(Script::new(EMPTY_SCRIPT.to_vec(), vec![], vec![]))
        .sequence_number(seq_num)
        .max_gas_amount(max_gas_amount)
        .gas_unit_price(gas_unit_price)
        .gas_currency_code(&gas_currency_code)
        .sign()
}

/// Returns a transaction to create a new account with the given arguments.
pub fn create_account_txn(
    sender: &Account,
    new_account: &Account,
    seq_num: u64,
    initial_amount: u64,
    type_tag: TypeTag,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::Address(*new_account.address()));
    args.push(TransactionArgument::U8Vector(new_account.auth_key_prefix()));
    args.push(TransactionArgument::U64(initial_amount));

    sender
        .transaction()
        .script(Script::new(
            CREATE_ACCOUNT_SCRIPT.to_vec(),
            vec![type_tag],
            args,
        ))
        .sequence_number(seq_num)
        .sign()
}

/// Returns a transaction to transfer coin from one account to another (possibly new) one, with the
/// given arguments.
pub fn peer_to_peer_txn(
    sender: &Account,
    receiver: &Account,
    seq_num: u64,
    transfer_amount: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::Address(*receiver.address()));
    args.push(TransactionArgument::U64(transfer_amount));
    args.push(TransactionArgument::U8Vector(vec![]));
    args.push(TransactionArgument::U8Vector(vec![]));

    // get a SignedTransaction
    sender
        .transaction()
        .script(Script::new(
            StdlibScript::PeerToPeerWithMetadata
                .compiled_bytes()
                .into_vec(),
            vec![lbr_type_tag()],
            args,
        ))
        .sequence_number(seq_num)
        .sign()
}

/// Returns a transaction to change the keys for the given account.
pub fn rotate_key_txn(sender: &Account, new_key_hash: Vec<u8>, seq_num: u64) -> SignedTransaction {
    let args = vec![TransactionArgument::U8Vector(new_key_hash)];
    sender
        .transaction()
        .script(Script::new(
            StdlibScript::RotateAuthenticationKey
                .compiled_bytes()
                .into_vec(),
            vec![],
            args,
        ))
        .sequence_number(seq_num)
        .sign()
}

/// Returns a transaction to change the keys for the given account.
pub fn raw_rotate_key_txn(sender: &Account, new_key_hash: Vec<u8>, seq_num: u64) -> RawTransaction {
    let args = vec![TransactionArgument::U8Vector(new_key_hash)];
    sender
        .transaction()
        .script(Script::new(
            StdlibScript::RotateAuthenticationKey
                .compiled_bytes()
                .into_vec(),
            vec![],
            args,
        ))
        .sequence_number(seq_num)
        .raw()
}
