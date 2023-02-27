use crate::app::dtos::{
    error_response::ErrorResponseDTO, pre_auth_request::PreAuthRequestDTO,
    pre_auth_response::PreAuthResponseDTO,
};
use async_trait::async_trait;

#[async_trait]
pub trait TDSProvider {
    async fn pre_auth(
        &self,
        pre_auth_request_dto: PreAuthRequestDTO,
    ) -> Result<PreAuthResponseDTO, ErrorResponseDTO>;
}
