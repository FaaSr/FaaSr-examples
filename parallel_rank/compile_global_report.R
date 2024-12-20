compile_global_report <- function(folder, stats_prefix, expected_regions) {
  
  files <- faasr_get_folder_list(faasr_prefix=folder)
  stats_files <- grep(paste0(stats_prefix, "_region_[0-9]+\\.csv$"), files, value=TRUE)
  
  if (length(stats_files) != expected_regions) {
    log_msg <- paste0("Error: Expected ", expected_regions, 
                      " regions but found ", length(stats_files))
    faasr_log(log_msg)
    return(FALSE)
  }
  
  all_stats <- data.frame()
  
  for (file in stats_files) {
    local_file <- basename(file)
    faasr_get_file(remote_folder=folder,
                   remote_file=local_file,
                   local_file=local_file)
    
    region_stats <- read.csv(local_file)
    all_stats <- rbind(all_stats, region_stats)
  }
  
  global_summary <- data.frame(
    total_regions = nrow(all_stats),
    global_avg_temp = mean(all_stats$avg_temp),
    highest_recorded_temp = max(all_stats$max_temp),
    lowest_recorded_temp = min(all_stats$min_temp),
    total_precipitation = sum(all_stats$total_precip),
    avg_humidity = mean(all_stats$avg_humidity),
    total_extreme_days = sum(all_stats$extreme_weather_days),
    regions_above_avg_temp = sum(all_stats$avg_temp > mean(all_stats$avg_temp))
  )
  
  write.csv(global_summary, "global_summary.csv", row.names=FALSE)
  faasr_put_file(local_file="global_summary.csv",
                 remote_folder=folder,
                 remote_file="global_weather_summary.csv")
  
  log_msg <- "Generated global weather analysis report"
  faasr_log(log_msg)
  return(TRUE)
}