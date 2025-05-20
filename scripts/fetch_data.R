# R/fetch_data.R
library(httr)
library(jsonlite)
source("config/config.R")
source("R/logging.R")
source("R/email_alerts.R")

fetch_air_quality <- function(city, lat, lon, api_key, max_attempts = 1) {
  url <- paste0("http://api.openweathermap.org/data/2.5/air_pollution?lat=", lat, "&lon=", lon, "&appid=", api_key)
  attempt <- 1
  success <- FALSE
  result <- NULL
  
  while (attempt <= max_attempts && !success) {
    response <- GET(url)
    status <- status_code(response)
    log_message(paste("API Request for:", city, "Response Code:", status))
    
    if (status == 200) {
      data_json <- fromJSON(content(response, as = "text", encoding = "UTF-8"), flatten = TRUE)
      if (!is.null(data_json$list) && length(data_json$list) > 0) {
        record <- data_json$list[[1]]
        result <- data.frame(
          City = city,
          Timestamp = as.POSIXct(record$dt, origin = "1970-01-01", tz = "UTC"),
          PM2.5 = record$components$pm2_5,
          PM10 = record$components$pm10,
          CO = record$components$co,
          NO2 = record$components$no2,
          SO2 = record$components$so2,
          O3 = record$components$o3,
          AQI = record$main$aqi,
          Descriptor = c("Good", "Fair", "Moderate", "Poor", "Very Poor")[record$main$aqi],
          stringsAsFactors = FALSE
        )
        print(result)
        success <- TRUE
      }
    } else {
      log_message(paste("Error fetching", city, "- Status code:", status))
      send_failure_alert(paste("API request failed for", city, "with status code:", status))
      if (status == 401) {
        log_message("Invalid API key detected. Please check and update the key.")
      }
    }
    attempt <- attempt + 1
    Sys.sleep(2)
  }
  return(result)
}

run_data_collection <- function(api_key) {
  data_list <- lapply(1:nrow(cities), function(i) {
    row <- cities[i, ]
    fetch_air_quality(row$City, row$Lat, row$Lon, api_key)
  })
  combined_data <- do.call(rbind, data_list)
  log_message("Fetched Air Quality Data:")
  print(combined_data)
  if (!is.null(combined_data)) {
    store_data(combined_data)
  }
  return(combined_data)
}
