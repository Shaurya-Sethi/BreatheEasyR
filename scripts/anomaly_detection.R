# R/anomaly_detection.R
library(forecast)
library(dplyr)
source("R/logging.R")

detect_anomalies <- function(data) {
  anomalies <- data.frame()
  for (city in unique(data$City)) {
    city_data <- data %>% filter(City == city) %>% arrange(Timestamp)
    if (nrow(city_data) >= 10) {
      ts_data <- ts(city_data$`PM2.5`, frequency = 24)
      decomp <- stl(ts_data, s.window = "periodic")
      resid <- decomp$time.series[, "remainder"]
      threshold <- 2 * sd(resid, na.rm = TRUE)
      city_data$anomaly <- abs(resid) > threshold
      city_data$alert_level <- ifelse(city_data$anomaly,
                                      ifelse(abs(resid) > 3 * sd(resid, na.rm = TRUE),
                                      "Red", "Yellow"),
                                      "Normal")
      anomalies <- rbind(anomalies, city_data)
    }
  }
  log_message("Detected Anomalies:")
  print(anomalies)
  return(anomalies)
}
