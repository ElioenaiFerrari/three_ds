use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub enum ProtocolVersion {
    #[serde(rename(serialize = "2.2.0", deserialize = "2.2.0"))]
    V220,
    #[serde(rename(serialize = "2.1.0", deserialize = "2.1.0"))]
    V210,
}
