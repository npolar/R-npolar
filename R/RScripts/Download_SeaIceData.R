
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## 
    ## Download sea ice data from Univ. Bremen's online repository
    ## for a specific time interval
    ## and saves as GeoTiff format
    ##
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#   output.dir        path to your output folders, e.g.  "C:/Documents/IceData"
#   date.start        must be of the following format "YYYY-mm-dd"
#   date.end          must be of the following format "YYYY-mm-dd"
#   date.interval     data will be downloaded at this interval from date.start to date.end
#   hemis             "n" for Northern, "s" for Southern
#   date.list         if working with a specific list of dates

dwnld.iceData <- function(output.dir, hemis = "n", date.start, date.end, date.interval = 3, date.list = NULL){
  
  require(RCurl);  require(raster)

  # Temporarily changing Locale
    tz <- Sys.getenv("TZ")
    lg <- Sys.getlocale("LC_TIME")
    Sys.setenv(TZ='GMT')
    Sys.setlocale("LC_TIME", "English")
  
  if (is.null(date.list)) {
      date.start <- as.POSIXct(strptime(date.start,"%Y-%m-%d"), "GMT")
      date.end   <- as.POSIXct(strptime(date.end,"%Y-%m-%d"), "GMT")
      dates      <- format(seq(date.start, date.end, by= 86400 * date.interval),"%Y%m%d")
    } else {
      dates  <- format(strptime(date.list, "%Y-%m-%d"), "%Y%m%d")
    }
  
  missing.dates <- NULL
  for (d in dates){
    
    # Define your file names based on selected dates and hemisphere
    yr        <- substr(d, 1,4)
    mn        <- tolower(format(strptime(d, "%Y%m%d"), "%b"))
    file.name <- paste ("http://www.iup.physik.uni-bremen.de:8084/ssmisdata/asi_daygrid_swath/", hemis, "6250/", yr, "/", mn, "/asi-SSMIS-", hemis, "6250-",d,"-v5.tif",sep="")
    
    # Check that the file is actually available
    cc         <- try(download.file(file.name,  destfile = rasterTmpFile(prefix='raster_tmp_'), quiet = TRUE), silent=TRUE)
    
    if(is(cc,"try-error")) {
      missing.dates <- append(missing.dates, d); print(paste("missing file for", d)); next
      } else {
        cat(paste(d, "available..."), sep="\n")
        download.file(file.name,  mode = "wb", destfile = paste(output.dir, "/asi-SSMIS-", hemis, "6250-",d,"-v5.tif", sep = ""))
      }
  }
  
  # Putting things back as they were
    Sys.setenv(TZ=tz)
    try(Sys.setlocale("LC_TIME", lg), silent = TRUE)
    removeTmpFiles(h=0)
}    

