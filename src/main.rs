mod app;
mod domain;
mod infra;
use actix_web::{post, web, App, HttpResponse, HttpServer, Responder};
use app::{commands::pre_auth, dtos::pre_auth_request::PreAuthRequestDTO};
use infra::adapters::tds_secure_io;
use std::io::Result;

#[post("/pre_auth")]
async fn pre_auth_handler(params: web::Json<PreAuthRequestDTO>) -> impl Responder {
    let tds_provider = tds_secure_io::new();
    let pre_auth_command = pre_auth::new(tds_provider);
    let res = pre_auth_command.call(PreAuthRequestDTO {
        account_number: params.account_number.parse().unwrap(),
    });

    return HttpResponse::Ok().json(res.await.unwrap_err());
}

#[actix_web::main]
async fn main() -> Result<()> {
    HttpServer::new(|| App::new().service(web::scope("/api/v1").service(pre_auth_handler)))
        .workers(4)
        .bind(("127.0.0.1", 4000))?
        .run()
        .await
}
