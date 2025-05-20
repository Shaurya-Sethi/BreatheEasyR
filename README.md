# BreatheEasyR

## Real-Time Air Quality Monitoring and Anomaly Detection in R

---

## Overview

**BreatheEasyR** is an R-based system for real-time monitoring, anomaly detection, and visualization of air quality data across major global cities. It fetches live pollution and Air Quality Index (AQI) data using the OpenWeatherMap API, stores the data in a local SQLite database, detects anomalies in pollution levels using time-series models, and provides both temporal and geospatial visualizations. The solution is robust, featuring error handling, logging, and email alerts for failure recovery.

## Key Features

* Fetches real-time air quality and AQI data for multiple cities from the OpenWeatherMap API
* Stores structured air quality records in a local SQLite database, ensuring historical trends are preserved
* Detects pollution anomalies (spikes, unusual changes) using time-series decomposition and statistical thresholds
* Provides dynamic time-series plots (Plotly) and interactive city maps (Leaflet) for intuitive visualization
* Implements robust logging and automated data collection, including error handling and email alerts for failures
* Modular codebase for easy extension and integration

## Folder Structure

```
BreatheEasyR/
├── config/
│   └── config.R                  # Project configuration and city coordinates
├── data/                         # SQLite database and logs (auto-created, gitignored)
├── scripts/
│   ├── anomaly_detection.R       # Anomaly detection logic
│   ├── email_alerts.R            # Email alert utilities
│   ├── fetch_data.R              # API fetching logic
│   ├── logging.R                 # Logging utilities
│   ├── main.R                    # Main entry point
│   ├── store_data.R              # Database interaction functions
│   └── visualization.R           # Visualization functions
│   └── schedule_task.R           # Automation script for scheduled runs
├── .gitignore
├── .Renviron.example             # Template for environment variables (API/email creds)
├── README.md
└── requirements.txt              # Required R packages
```

## Requirements

* **R 4.1 or higher**
* The following R packages (install using `install.packages()`):

  * httr
  * jsonlite
  * dplyr
  * DBI
  * RSQLite
  * forecast
  * plotly
  * leaflet
  * blastula

## Setup Instructions

### 1. Clone the repository

```sh
git clone https://github.com/Shaurya-Sethi/BreatheEasyR.git
cd BreatheEasyR
```

### 2. Install required R packages

Open R or RStudio and run:

```R
packages <- c("httr", "jsonlite", "dplyr", "DBI", "RSQLite", "forecast", "plotly", "leaflet", "blastula")
install.packages(packages)
```

### 3. Set up environment variables for API and SMTP credentials

1. **Copy** the `.Renviron.example` file to `.Renviron` in your project root:

   ```sh
   cp .Renviron.example .Renviron
   ```

2. **Edit** `.Renviron` and add your real credentials:

   ```text
   OPENWEATHER_API_KEY=your_openweather_api_key_here
   SMTP_USER=your_email@gmail.com
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=465
   SMTP_SSL=TRUE
   SMTP_PASSWORD=your_email_app_password_here
   ```

   * *Never commit your real `.Renviron` file to version control.*

3. Restart your R session to load the new environment variables.

## How to Use

### 1. Main Script Execution

* The primary entry point is `scripts/main.R`.
* To start monitoring, run in your R session:

  ```R
  source("config/config.R")
  source("scripts/main.R")
  ```
* The script will:

  1. Fetch real-time air quality data for all configured cities
  2. Store new unique records in the SQLite database under `data/air_quality.db`
  3. Run anomaly detection and categorize pollution spikes
  4. Generate interactive time-series and map visualizations in your R session
  5. Log all operations to `data/air_quality_log.txt`
  6. Send an email alert if a critical API error or repeated failure occurs

### 2. Automation (Optional)

* For automated periodic data collection, use [taskscheduleR](https://cran.r-project.org/web/packages/taskscheduleR/index.html) (Windows) or cron jobs (Linux/Mac) to schedule `main.R` to run at desired intervals (e.g., every 15 minutes).

## Automating Data Collection

To automate periodic data collection, you can schedule the `main.R` script to run at your desired interval on any operating system.

### **A. Automation on Windows (using `taskscheduleR`):**

1. **Install and load the package:**

   ```R
   install.packages("taskscheduleR")
   library(taskscheduleR)
   ```

2. **Use the provided script to schedule runs every 15 minutes:**

   Create and run `scripts/schedule_task.R`:

   ```R
   library(taskscheduleR)

   main_script <- normalizePath("scripts/main.R")
   task_name <- "BreatheEasyR_Monitor"

   taskscheduler_create(
     taskname   = task_name,
     rscript    = main_script,
     schedule   = "MINUTE",
     starttime  = format(Sys.time() + 62, "%H:%M"),
     modifier   = 15,
     Rexe       = file.path(R.home("bin"), "Rscript.exe"),
     logfile    = normalizePath("data/task_log.txt"),
     invisible  = TRUE
   )
   cat(paste0("Scheduled task '", task_name, "' to run every 15 minutes.\n"))
   ```

   Run once in R to set up the automated task.

3. **To remove the task later:**

   ```R
   taskscheduler_delete(taskname = "BreatheEasyR_Monitor")
   ```

### **B. Automation on Linux/macOS (using `cron`):**

1. **Open your terminal and type:**

   ```sh
   crontab -e
   ```

2. **Add the following line to run every 15 minutes:**

   ```sh
   */15 * * * * cd /path/to/BreatheEasyR && Rscript scripts/main.R >> data/task_log.txt 2>&1
   ```

   * Replace `/path/to/BreatheEasyR` with your project directory.
   * Make sure `Rscript` is in your system path.
   * Output and errors are logged to `data/task_log.txt`.

3. **Save and exit.**


## Customization

* **City List**: Edit the `cities` data frame in `config/config.R` to monitor other locations (provide latitude and longitude).
* **Alert Logic**: Adjust statistical thresholds in `scripts/anomaly_detection.R` to tune anomaly sensitivity.
* **Visualizations**: Modify `scripts/visualization.R` for new plots or map features.
* **Database/Logs**: Data and logs are stored in `/data/` (auto-created if not present).

## Security and Good Practices

* **Do not commit** your `.Renviron` or `data/` directory. Sensitive credentials should only reside locally.
* For Gmail SMTP, set up [App Passwords](https://support.google.com/accounts/answer/185833?hl=en) if you have 2FA enabled.
* If a credential is leaked, revoke it immediately in the provider's dashboard.

## Troubleshooting

* If emails are not sent, check your SMTP credentials and verify they are loaded (see R's `Sys.getenv()` output).
* If no data is stored, ensure your OpenWeather API key is valid and has quota.
* For time-series analysis, ensure at least 10 records per city for accurate anomaly detection.
* If you want to manually test failure handling, temporarily set an invalid API key or interrupt your network.

## Acknowledgments

* Air quality data provided by [OpenWeatherMap](https://openweathermap.org/api/air-pollution).
* Visualization packages: [plotly](https://plotly.com/r/), [leaflet](https://rstudio.github.io/leaflet/)
* Email notifications: [blastula](https://cran.r-project.org/web/packages/blastula/)

## License

This project is provided for educational and research purposes. Please review the LICENSE file for more information.
