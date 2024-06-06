count_CRAN_downloads <- function(startdate, enddate, packagename, folder) {
    # count the number of CRAN downloads for a given packagename for a specified period
    # store a summary as a CSV file in the S3 bucket at the named folder
    # startdate and enddate are in the format: 2024-06-03'
    # based on the example described in: http://cran-logs.rstudio.com/
    # example: count_CRAN_downloads('2024-06-03','2024-06-04','processx','CRAN_downloads_output')

  start <- as.Date(startdate)
  today <- as.Date(enddate)
  all_days <- seq(start, today, by = 'day')
  year <- as.POSIXlt(all_days)$year + 1900
  # obtain the list of URLs
  urls <- paste0('http://cran-logs.rstudio.com/', year, '/', all_days, '.csv.gz')
  # initialize count
  hitcount <- 0
  # give a longer timeout than default 60s
  options(timeout=360)

  # traverse all URLs
  for (u in 1:length(urls)) {
    # download a file, load into memory, then remove from disk
    download.file(urls[u],destfile="tmp.csv.gz")
    tmp <- read.table(gzfile("tmp.csv.gz")) 
    file.remove("tmp.csv.gz")
    # traverse the table and count matches
    for(x in tmp$V2) {
      hit <- grepl(packagename,x)
      if (hit == TRUE) {
        hitcount <- hitcount + 1
      }
    }
  }
  # generate local CSV output; 
  # the file name is the concatenation of start and end date
  # the contents are the package name and hit count
  outputfile <- paste(startdate,'_',enddate,'.csv',sep="")
  outputline <- paste(packagename,startdate,enddate,hitcount,sep=',')
  write(outputline,file=outputfile,append=TRUE)
  # Now upload to S3 and log using FaaSr
  faasr_put_file(local_file=outputfile, remote_folder=folder, remote_file=outputfile)
  faasr_log("count_CRAN_downloads successfully completed")
}
