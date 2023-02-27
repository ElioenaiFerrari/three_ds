use crate::domain::value_objects::protocol_version::ProtocolVersion;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct PreAuthResponseDTO {
    #[serde(rename(serialize = "protocol_version", deserialize = "dsEndProtocolVersion"))]
    pub protocol_version: ProtocolVersion,
    #[serde(rename(serialize = "transaction_id", deserialize = "threeDSServerTransID"))]
    pub transaction_id: String,
    #[serde(rename(serialize = "tds_method_url", deserialize = "threeDSMethodURL"))]
    pub tds_method_url: String,
}
