use actix_web::{get, App, HttpResponse, HttpServer, Responder};
mod user;
use user::TEST_USER;

#[get("/user")]
async fn get_user() -> impl Responder {
    HttpResponse::Ok().json(TEST_USER)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new().service(get_user)
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}