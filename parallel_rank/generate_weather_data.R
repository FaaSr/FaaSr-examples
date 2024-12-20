generate_weather_data <- function(folder, region_prefix, num_regions) {
  for(region in 1:num_regions) {
    
    days <- 365
    set.seed(region)
    
    weather_data <- data.frame(
      date = seq(as.Date("2023-01-01"), by="day", length.out=days),
      temperature = rnorm(days, mean=20, sd=8),
      humidity = runif(days, min=30, max=90),
      precipitation = rexp(days, rate=1/5),
      wind_speed = rnorm(days, mean=15, sd=5)
    )
    
    weather_data$temperature <- weather_data$temperature + (num_regions - region) * 5
    

    precip_factor <- 1 - abs(region - (num_regions/2))/(num_regions/2)
    weather_data$precipitation <- weather_data$precipitation * (1 + precip_factor)

    local_file <- paste0("region_", region, "_weather.csv")
    write.csv(weather_data, local_file, row.names=FALSE)
    

    remote_file <- paste0(region_prefix, "_region_", region, "_weather.csv")
    faasr_put_file(local_file=local_file, 
                   remote_folder=folder, 
                   remote_file=remote_file)
    
    log_msg <- paste0("Generated weather data for region ", region)
    faasr_log(log_msg)
  }
  
  log_msg <- paste0("Completed generating weather data for all ", num_regions, " regions")
  faasr_log(log_msg)
}