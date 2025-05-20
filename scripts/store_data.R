# R/store_data.R
library(DBI)
library(RSQLite)
library(dplyr)
source("config/config.R")
source("R/logging.R")

store_data <- function(data) {
  con <- dbConnect(SQLite(), db_path)
  if (!dbExistsTable(con, "air_quality")) {
    dbCreateTable(con, "air_quality", data)
  }
  existing <- dbGetQuery(con, "SELECT City, Timestamp FROM air_quality")
  if (nrow(existing) > 0) {
    existing$Timestamp <- as.POSIXct(existing$Timestamp, origin = "1970-01-01", tz = "UTC")
  }
  data$Timestamp <- as.POSIXct(data$Timestamp, origin = "1970-01-01", tz = "UTC")
  new_data <- anti_join(data, existing, by = c("City", "Timestamp"))
  if (nrow(new_data) > 0) {
    dbWriteTable(con, "air_quality", new_data, append = TRUE)
    log_message("Stored new data:")
    print(new_data)
  } else {
    log_message("No new unique records to store.")
  }
  dbDisconnect(con)
}
