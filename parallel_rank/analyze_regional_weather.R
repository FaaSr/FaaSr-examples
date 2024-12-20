analyze_regional_weather <- function(folder, region_prefix, stats_prefix,output_folder) {
  
  rank_list <- FaaSr::faasr_rank()
  rank_number <- rank_list$Rank
  rank_max <- rank_list$MaxRank

  remote_file <- paste0(region_prefix, "_region_", rank_number, "_weather.csv")
  local_file <- paste0("region_", rank_number, "_weather.csv")
  
  faasr_get_file(remote_folder=folder, 
                 remote_file=remote_file, 
                 local_file=local_file)

  weather_data <- read.csv(local_file)
  
  regional_stats <- data.frame(
    region = rank_number,
    avg_temp = mean(weather_data$temperature),
    max_temp = max(weather_data$temperature),
    min_temp = min(weather_data$temperature),
    total_precip = sum(weather_data$precipitation),
    avg_humidity = mean(weather_data$humidity),
    avg_wind = mean(weather_data$wind_speed),
    extreme_weather_days = sum(weather_data$temperature > 30 | 
                                 weather_data$precipitation > 50)
  )
  
  local_stats_file <- paste0("stats_region_", rank_number, ".csv")
  write.csv(regional_stats, local_stats_file, row.names=FALSE)
  
  remote_stats_file <- paste0(stats_prefix, "_region_", rank_number, ".csv")
  faasr_put_file(local_file=local_stats_file,
                 remote_folder=output_folder,
                 remote_file=remote_stats_file)
  
  log_msg <- paste0("Analyzed weather data for region ", rank_number, " out of ", rank_max)
  faasr_log(log_msg)
}