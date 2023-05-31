use actix_web::{get, App, HttpRequest, HttpResponse, HttpServer};
use chrono::DateTime;
use chrono::Local;
use std::env;
use reqwest;

#[get("/")]
async fn index(request: HttpRequest) -> HttpResponse {
    let author = env::var("AUTHOR").unwrap_or_else(|_| String::from("Unknown author"));
    let port = env::var("PORT").unwrap_or_else(|_| String::from("Unknown port"));
    let ipgeolocation_api_key = env::var("IPGEOLOCATION_API_KEY").unwrap_or_else(|_| String::from("YOUR_DEFAULT_API_KEY"));
    let now: DateTime<Local> = Local::now();
    let client_ip = request
        .connection_info()
        .realip_remote_addr()
        .map(|ip| ip.to_string())
        .unwrap_or_else(|| String::from("Unknown IP"));
    let geolocation_url = format!("https://api.ipgeolocation.io/ipgeo?apiKey={}&ip={}", ipgeolocation_api_key, client_ip);

    let response_text: Option<String> = match reqwest::get(&geolocation_url).await {
        Ok(response) => match response.text().await {
            Ok(text) => Some(text),
            Err(err) => {
                println!("Error retrieving response text: {}", err);
                None
            }
        },
        Err(err) => {
            println!("Error performing request: {}", err);
            None
        }
    };
    let current_time: Option<String> = match response_text {
        Some(response_text) => {
            let json: serde_json::Value = serde_json::from_str(&response_text).unwrap_or(serde_json::Value::Null);
            if let Some(timezone) = json.get("time_zone") {
                if let Some(current_time) = timezone.get("current_time") {
                    Some(current_time.as_str().unwrap_or("").to_string())
                } else {
                    None
                }
            } else {
                None
            }
        }
        None => None,
    };

    let response_body = format!(
        "Request received at: {}\nAuthor: {}\nPort: {}\nClient IP: {}\nCurrent Time: {}",
        now.format("%Y-%m-%d %H:%M:%S"),
        author,
        port,
        client_ip,
        current_time.unwrap_or_else(|| String::from("Unknown"))
    );

    HttpResponse::Ok().body(response_body)
}

#[actix_rt::main]
async fn main() -> std::io::Result<()> {
    env::set_var("RUST_LOG", "debug"); // Ustawienie poziomu logowania na "info"
    env_logger::init(); // Inicjalizacja loggera env_logger
    let author = "Artur Gawrylak";
    let port = "8000";
    let address = format!("0.0.0.0:{}", port);
    let now: DateTime<Local> = Local::now();

    log::info!("Author: {}", author);
    log::info!("Port: {}", port);
    log::info!("Start time: {}", now.format("%Y-%m-%d %H:%M:%S"));
    HttpServer::new(|| App::new().service(index))
        .bind(address)?
        .run()
        .await
}