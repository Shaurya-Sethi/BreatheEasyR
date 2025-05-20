# config/config.R
api_key <- Sys.getenv("OPENWEATHER_API_KEY")
db_path <- "data/air_quality.db"
log_file <- "data/air_quality_log.txt"

cities <- data.frame(
  City = c("New York", "Los Angeles", "London", "Paris", "Beijing", "Mumbai"),
  Lat  = c(40.7128, 34.0522, 51.5074, 48.8566, 39.9042, 19.0760),
  Lon  = c(-74.0060, -118.2437, -0.1278, 2.3522, 116.4074, 72.8777),
  stringsAsFactors = FALSE
)
