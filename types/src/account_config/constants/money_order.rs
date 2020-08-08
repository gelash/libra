// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use move_core_types::{
    identifier::{IdentStr, Identifier},
};
use once_cell::sync::Lazy;

pub const MONEY_ORDER_MODULE_NAME: &str = "MoneyOrder";

// Money Order Events
static CANCELED_EVENT_NAME: Lazy<Identifier> =
    Lazy::new(|| Identifier::new("CanceledMoneyOrderEvent").unwrap());
static ISSUED_EVENT_NAME: Lazy<Identifier> =
    Lazy::new(|| Identifier::new("IssuedMoneyOrderEvent").unwrap());
static REDEEMED_EVENT_NAME: Lazy<Identifier> =
    Lazy::new(|| Identifier::new("RedeemedMoneyOrderEvent").unwrap());

pub fn canceled_event_name() -> &'static IdentStr {
    &*CANCELED_EVENT_NAME
}

pub fn issued_event_name() -> &'static IdentStr {
    &*ISSUED_EVENT_NAME
}

pub fn redeemed_event_name() -> &'static IdentStr {
    &*REDEEMED_EVENT_NAME
}
