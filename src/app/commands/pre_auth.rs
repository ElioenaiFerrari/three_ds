use crate::app::{
    dtos::{
        error_response::ErrorResponseDTO, pre_auth_request::PreAuthRequestDTO,
        pre_auth_response::PreAuthResponseDTO,
    },
    protocols::tds_provider::TDSProvider,
};

pub struct PreAuthCommand {
    tds_provider: Box<dyn TDSProvider>,
}

pub fn new(tds_provider: Box<dyn TDSProvider>) -> PreAuthCommand {
    return PreAuthCommand {
        tds_provider: tds_provider,
    };
}

impl PreAuthCommand {
    pub async fn call(
        &self,
        pre_auth_request_dto: PreAuthRequestDTO,
    ) -> Result<PreAuthResponseDTO, ErrorResponseDTO> {
        return self.tds_provider.pre_auth(pre_auth_request_dto).await;
    }
}
