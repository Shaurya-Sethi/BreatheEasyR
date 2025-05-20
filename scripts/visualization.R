# R/visualization.R
library(plotly)
library(leaflet)
library(dplyr)
source("config/config.R")

visualize_time_series <- function(data, pollutant = "PM2.5") {
  p <- plot_ly(data,
               x = ~Timestamp,
               y = as.formula(paste0("~`", pollutant, "`")),
               type = 'scatter',
               mode = 'lines+markers',
               color = ~City) %>%
    layout(title = paste("Time Series of", pollutant),
           xaxis = list(title = "Timestamp"),
           yaxis = list(title = pollutant))
  print(p)
}

visualize_map <- function(data) {
  latest_data <- data %>%
    group_by(City) %>%
    filter(Timestamp == max(Timestamp)) %>%
    ungroup() %>%
    left_join(cities, by = "City")
  color_palette <- colorFactor(
    palette = c("green", "yellow", "orange", "red", "purple"),
    domain = c(1, 2, 3, 4, 5)
  )
  m <- leaflet(latest_data) %>%
    addTiles() %>%
    addCircleMarkers(
      lng = ~Lon, lat = ~Lat,
      popup = ~paste0(
        "<b>", City, "</b><br>",
        "AQI: ", AQI, "<br>",
        "Pollution Level: ", Descriptor
      ),
      color = ~color_palette(AQI),
      fillOpacity = 0.8,
      radius = 8
    )
  print(m)
}
