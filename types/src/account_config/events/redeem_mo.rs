// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

// use crate::account_address::AccountAddress;
use anyhow::Result;
use move_core_types::move_resource::MoveResource;
use serde::{Deserialize, Serialize};

/// Struct that represents a NewBlockEvent.
#[derive(Debug, Serialize, Deserialize)]
pub struct RedeemedMoneyOrderEvent {
    pub amount: u64,
    pub batch_index: u64,
    pub order_index: u64,
}

impl RedeemedMoneyOrderEvent {

    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        lcs::from_bytes(bytes).map_err(Into::into)
    }
}

impl MoveResource for RedeemedMoneyOrderEvent {
    const MODULE_NAME: &'static str = "MoneyOrder";
    const STRUCT_NAME: &'static str = "RedeemedMoneyOrderEvent";
}
