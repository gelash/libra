// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use move_core_types::{
    identifier::{IdentStr, Identifier},
};
use once_cell::sync::Lazy;

pub const MONEY_ORDER_MODULE_NAME: &str = "MoneyOrder";

// Payment Events
static ISSUED_EVENT_NAME: Lazy<Identifier> =
    Lazy::new(|| Identifier::new("IssuedMoneyOrderEvent").unwrap());

pub fn issued_event_name() -> &'static IdentStr {
    &*ISSUED_EVENT_NAME
}
