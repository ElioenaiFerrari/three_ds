use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub enum TransactionIndicator {
    #[serde(rename(serialize = "account_verification_successfull", deserialize = "Y"))]
    AccountVerificationSuccessfull,
    #[serde(rename(serialize = "denied", deserialize = "N"))]
    Denied,
    #[serde(rename(serialize = "could_not_be_performed", deserialize = "U"))]
    CouldNotBePerformed,
    #[serde(rename(serialize = "additional_authentication_required", deserialize = "C"))]
    AdditionalAuthenticationRequired,
    #[serde(rename(serialize = "issuer_rejecting_authentication", deserialize = "R"))]
    IssuerRejectingAuthentication,
    #[serde(rename(serialize = "information_only", deserialize = "I"))]
    InformationOnly,
    #[serde(rename(serialize = "attempts_processing_performed", deserialize = "A"))]
    AttemptsProcessingPerformed,
    #[serde(rename(serialize = "decoupled_authentication_required", deserialize = "D"))]
    DecoupledAuthenticationRequired,
}
