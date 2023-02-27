use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct PreAuthRequestDTO {
    #[serde(rename(serialize = "acctNumber", deserialize = "account_number"))]
    pub account_number: String,
}
