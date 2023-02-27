use crate::app::dtos::{
    error_response::ErrorResponseDTO, pre_auth_request::PreAuthRequestDTO,
    pre_auth_response::PreAuthResponseDTO,
};
use crate::app::protocols::tds_provider::TDSProvider;
use async_trait::async_trait;
use reqwest::header::{HeaderMap, HeaderValue, CONTENT_TYPE};
use std::env;

pub struct TDSSecureIOAdapter {
    base_url: String,
    client_http: reqwest::Client,
}

pub fn new() -> Box<TDSSecureIOAdapter> {
    let mut headers: HeaderMap = HeaderMap::new();
    let api_key = env::var("TDS_API_KEY").expect("TDS_API_KEY not found");
    let base_url = env::var("TDS_BASE_URL").expect("TDS_BASE_URL not found");
    let mut api_key_header: HeaderValue = api_key.parse().expect("invalid header");
    let content_type_header: HeaderValue = "application/json; charset=UTF-8"
        .parse()
        .expect("invalid header");

    api_key_header.set_sensitive(true);
    headers.insert("APIKey", api_key_header);
    headers.insert(CONTENT_TYPE, content_type_header);

    let pem = std::fs::read("cert.pem").expect("certificate not found");
    let cert = reqwest::Certificate::from_pem(&pem).expect("invalid certficate");
    let client_http = reqwest::ClientBuilder::new()
        .default_headers(headers)
        .add_root_certificate(cert)
        .build()
        .expect("error when build client http");

    return Box::new(TDSSecureIOAdapter {
        base_url: base_url,
        client_http: client_http,
    });
}

#[async_trait]
impl TDSProvider for TDSSecureIOAdapter {
    async fn pre_auth(
        &self,
        pre_auth_request_dto: PreAuthRequestDTO,
    ) -> Result<PreAuthResponseDTO, ErrorResponseDTO> {
        let response = self
            .client_http
            .post(format!("{}/preauth", self.base_url))
            .json(&pre_auth_request_dto)
            .send()
            .await
            .unwrap();
        let json = response.text().await.unwrap();

        return match &json {
            x if x.contains("errorCode") => Err(serde_json::from_str(&json).unwrap()),
            _ => Ok(serde_json::from_str(&json).unwrap()),
        };
    }
}
