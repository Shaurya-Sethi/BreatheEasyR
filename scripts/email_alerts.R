# R/email_alerts.R
library(blastula)

send_failure_alert <- function(error_message) {
  email <- compose_email(
    body = md(paste0("**Alert:** Air quality data collection failed.\n\nError details: ", error_message))
  )
  smtp_send(
    email,
    from = Sys.getenv("SMTP_USER"),
    to = "your_email@gmail.com", # Change as needed
    subject = "Air Quality Data Collection Alert",
    credentials = creds(
      user = Sys.getenv("SMTP_USER"),
      provider = "gmail",
      host = Sys.getenv("SMTP_HOST"),
      port = as.numeric(Sys.getenv("SMTP_PORT")),
      use_ssl = as.logical(Sys.getenv("SMTP_SSL"))
    )
  )
  log_message(paste("Alert email sent:", error_message))
}
