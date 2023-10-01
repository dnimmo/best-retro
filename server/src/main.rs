// Import necessary crates and modules
use actix_web::{get, App, HttpResponse, HttpServer, Responder, middleware::Logger};
use actix_cors::Cors;
mod user;
use user::TEST_USER;
use serde::{Serialize, Deserialize};

// Define a struct to represent a user
#[derive(Debug, Serialize, Deserialize)]
struct User {
    name: String,
    age: u8,
}

// Define a handler function to return a JSON response containing a test user
#[get("/user")]
async fn get_user() -> impl Responder {
    HttpResponse::Ok().json(TEST_USER)
}

// Define the main function
#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Create a new HTTP server
    HttpServer::new(move || {
        // Create a new CORS middleware with permissive settings
        let cors = Cors::default()
            .allow_any_origin()
            .allowed_methods(vec!["GET"])
            .allowed_headers(vec!["Authorization", "Content-Type"])
            .max_age(3600);

        // Create a new Actix web application
        App::new()
            // Add a logging middleware to the application
            .wrap(Logger::default())
            // Add the `get_user` function as a service to the application
            .service(get_user)
            // Add the CORS middleware to the application
            .wrap(cors)
    })
    // Bind the server to a specific IP address and port
    .bind("127.0.0.1:8080")?
    // Start the server
    .run()
    .await
}