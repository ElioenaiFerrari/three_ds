use crate::domain::value_objects::{
    protocol_version::ProtocolVersion, transaction_indicator::TransactionIndicator,
};

#[derive(Debug)]
pub struct Transaction {
    pub id: String,

    pub authentication_value: String,
    pub challenge_complete_indicator: TransactionIndicator,
    pub eci: String,
    pub method_complete_indicator: TransactionIndicator,
    pub protocol_version: ProtocolVersion,
    pub status: TransactionIndicator,
    pub status_reason: String,
}

impl Transaction {}
