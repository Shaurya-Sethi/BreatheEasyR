# R/main.R
source("config/config.R")
source("R/logging.R")
source("R/fetch_data.R")
source("R/store_data.R")
source("R/anomaly_detection.R")
source("R/visualization.R")

main <- function() {
  log_message("Script started.")
  new_data <- run_data_collection(api_key)
  if (!is.null(new_data)) {
    anomalies <- detect_anomalies(new_data)
    log_message("Generating Visualizations...")
    visualize_time_series(new_data, "PM2.5")
    visualize_map(new_data)
  }
}

main()
