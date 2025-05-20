# This script Schedules your main script to run every 15 minutes, starting a minute from now.
# Writes output/errors to data/task_log.txt.
# Uses the system Rscript.exe so it works outside RStudio.
# Runs invisibly (no GUI pop-up).

library(taskscheduleR)

# Path to your Rscript (main entry point)
main_script <- normalizePath("scripts/main.R")

# Give a unique task name for the Windows Task Scheduler
task_name <- "BreatheEasyR_Monitor"

# Schedule to run every 15 minutes
taskscheduler_create(
  taskname   = task_name,
  rscript    = main_script,
  schedule   = "MINUTE",
  starttime  = format(Sys.time() + 62, "%H:%M"), # starts 1 minute from now
  modifier   = 15, # every 15 minutes
  Rexe       = file.path(R.home("bin"), "Rscript.exe"), # Auto-detects Rscript path
  logfile    = normalizePath("data/task_log.txt"),
  invisible  = TRUE
)
cat(paste0("Scheduled task '", task_name, "' to run every 15 minutes.\n"))

# Open R or RStudio in your project folder and run:
# source("scripts/schedule_task.R")
# You’ll see a confirmation message.
# You can check or manage scheduled tasks using the Windows Task Scheduler GUI or taskscheduler_ls() in R.

# To Remove the Task:
# If you want to delete the scheduled task:
# library(taskscheduleR)
# taskscheduler_delete(taskname = "BreatheEasyR_Monitor")
