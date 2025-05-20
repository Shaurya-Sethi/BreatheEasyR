# R/logging.R
log_message <- function(message) {
  formatted_message <- sprintf("\n%s - %s\n%s\n", Sys.time(), message, strrep("-", 50))
  cat(formatted_message, file = log_file, append = TRUE)
  cat(formatted_message)
}
