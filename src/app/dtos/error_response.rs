use crate::domain::value_objects::protocol_version::ProtocolVersion;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub enum Code {
    #[serde(rename(serialize = "message_received_invalid", deserialize = "101"))]
    MessageReceivedInvalid,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ErrorResponseDTO {
    #[serde(rename(serialize = "code", deserialize = "errorCode"))]
    pub code: Code,
    #[serde(rename(serialize = "component", deserialize = "errorComponent"))]
    pub component: String,
    #[serde(rename(serialize = "description", deserialize = "errorDetail"))]
    pub description: String,
    #[serde(rename(serialize = "message_type", deserialize = "messageType"))]
    pub message_type: String,
    #[serde(rename(serialize = "protocol_version", deserialize = "messageVersion"))]
    pub protocol_version: ProtocolVersion,
    #[serde(rename(serialize = "title", deserialize = "errorDescription"))]
    pub title: String,
}
