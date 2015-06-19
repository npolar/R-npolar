# npolar-download.R 
#   Download an entire Npolar API collection to disk. Slices the collection in one document per year, month, or day (interval).
#   
# Usage:
#  Rscript npolar-download.R {relative API path} {destination} {format} {interval} {intervalField}
#
# Authentication
#   Set R_NPOLAR_USERNAME and R_NPOLAR_USERNAME (only needed if the API endpoint has restricted access)
# 
# Examples
# * JSON replica of Dataset API organised by year created
# ✗ Rscript ./bin/npolar-download.R /dataset ./api.npolar.no json year created
#
# * CSV download of Svalbard Reindeer GPS tracks, with 1 document per month, and specified fields only
# ✗ Rscript ./bin/npolar-download.R /tracking/svalbard-reindeer /tmp/api.npolar.no csv month measured "measured,platform,latitude,longitude,altitude,activity_y,activity_x,hdop,temperature,time_to_fix,satellites,comment"
#
# * oceanography buoy JSON
# ✗ Rscript ./bin/npolar-download.R /oceanography/buoy /tmp/api.npolar.no
# Starting json download of /oceanography/buoy interval month measured to /tmp/api.npolar.no
# 37349 remote documents, most recent measured 
#  [{"measured":["2015-06-15T12:00:00Z"],"links":[{"title":["Deployment logs"],"rel":["log"],"href":["http://data.npolar.no/raw/buoy/deployment-logs/"]}],"collection":["buoy"],"type":["MetOcean i-svp"],"schema":["http://api.npolar.no/schema/oceanography_point-1.0.1"],"_rev":["1-1d734b7d88d06ffc85f0bcc1748902b5"],"id":["d35bd0da-7df2-5220-9d14-0e9ed8cefb75"],"title":["SVP_2015e"],"sea_surface_temperature":[2.8],"_id":["d35bd0da-7df2-5220-9d14-0e9ed8cefb75"],"IMEI":["300234010084440"],"air_pressure_tendency":[0.8],"owner":["FMI"],"air_pressure":[1010],"deployment":{"longitude":[15.0496],"latitude":[83.05],"date":["2015-04-20T10:00:00Z"]},"longitude":[-2.2954],"latitude":[77.2774]}]
# 6 month intervals using measured field
# Counts in existing local copy of 2015-01 matches API /oceanography/buoy count: 2171
# Counts in existing local copy of 2015-02 matches API /oceanography/buoy count: 6968
# Counts in existing local copy of 2015-03 matches API /oceanography/buoy count: 6290
# Counts in existing local copy of 2015-04 matches API /oceanography/buoy count: 5267
# Counts in existing local copy of 2015-05 matches API /oceanography/buoy count: 12427
# Fetching 2015-06 [ month 6 / 6 ] using http://api.npolar.no/oceanography/buoy?limit=1&variant=atom&q=&format=json&date-month=measured&sort=-measured&filter-measured=2015-06-01T00:00:00Z..2015-07-01T00:00:00Z&format=json&sort=measured&limit=all&variant=array
# Saving /tmp/api.npolar.no//oceanography/buoy/json/month-measured/2015-06-oceanography-buoy-npolar.json
# Counts in fresh local copy of 2015-06 matches API /oceanography/buoy count: 4226
#
# Dependencies
# * [httr](https://github.com/hadley/httr) - [quickstart](http://cran.r-project.org/web/packages/httr/vignettes/quickstart.html)
# * [jsonlite](https://github.com/jeroenooms/jsonlite) - [The jsonlite Package: A Practical and Consistent Mapping Between JSON Data and R Objects](http://arxiv.org/pdf/1403.2805v1.pdf)
#
# Notice: This is an initial draft version

source ("./R/api.R")

api.base <- "https://api.npolar.no"

api.download.fields <- function(path) {
  fields <- ""
  if (grepl("/tracking/svalbard-reindeer", path)) {  
    fields <- "measured,platform,latitude,longitude,altitude,activity_y,activity_x,hdop,temperature,time_to_fix,satellites,comment"
  }
  fields
}



api.get <- function(uri, headers) {

  username <- Sys.getenv("R_NPOLAR_USERNAME")
  password <- Sys.getenv("R_NPOLAR_PASSWORD")
  
  response <- httr::GET(uri, authenticate(username, password, "basic"), timeout(10))
  if (response$status_code > 299) {
    stop(paste("GET request failed with status", response$status_code, "for", uri, "\n", response))
  }
  httr::content(response, "text")
}

api.json <- function(uri) {
  json <- api.get(uri)
  jsonlite::fromJSON(json, simplifyVector = FALSE, simplifyDataFrame = FALSE)
}

api.download.count <- function(filename, format) {
  
  count <- 0
  if (grepl("csv", format)) {  
    count <- 0 # nrow(read.csv(filename))
  } else if (grepl("json", format)) {
    count <- length(fromJSON(filename, simplifyVector = FALSE, simplifyDataFrame = FALSE))
  }
  count 
}
      
api.download.intervalFacet <- function(feed, term) {

  vector = c()
  for(i in 1:length(feed$facets)){
    
    # Warning the double array feed$facets are deprecated WILL change in all Npolar APIs
    f <- feed$facets[i][[1]]
    facet = f[[term]]    
   
    if (length(facet) > 0) {
    
      for(c in 1:length(facet)) {
	uri <- facet[c]
	vector <- c(vector, uri)
      }
    }
  }
  vector
}

api.download <- function(path, destination="./api.npolar.no", format="json", interval="month", intervalField="measured", fields=NULL) {

  # Lookup default fields for this API path
  if (is.null(fields)) { fields <- api.download.fields(path) }

  if (is.na(destination)) { destination <- "./api.npolar.no" }
  if (is.na(format)) { format <- "json" }
  if (is.na(intervalField)) { intervalField <- "measured" }
  if (is.na(interval)) { interval <- "month" }
  
  query <- paste0("?q=&format=json&variant=atom&limit=1&date-",interval,"=",intervalField,"&sort=-",intervalField)
  uri <- paste0(api.base,path,query)

  message(paste("Starting", format, "download of", path, "interval", interval, intervalField, "to", destination))
  feed <- api.json(uri)$feed

  message(paste(feed$opensearch$totalResults, "remote documents, most recent", intervalField, "\n", toJSON(feed$entries)))

  j = 0
  term <- paste0(interval, "-", intervalField)

  facets = api.download.intervalFacet(feed, term)
  message(paste(length(facets), interval, "intervals using", intervalField, "field"))

  for (facet in facets) {
    
    j <- j+1
    uri <- paste0(facet$uri, "&format=", format, "&sort=", intervalField, "&limit=all")
    if (FALSE == is.na(fields)) {
      uri <- paste0(uri, "&fields=", fields)
    }
    if (grepl("json", format)) {
      uri <- paste0(uri, "&variant=", "array")
    }
    # Create filename like ./dataset/csv/year-created/2008-dataset.csv
    dir <- paste0(destination, "/", path, "/", format, "/", term)
    stem <- gsub("/", "-", gsub("^/", "", path))
    filename <- paste0(dir, "/", facet$term, "-", stem, "-", "npolar", ".", format)
    
    if (FALSE == file.exists(dir)) {
      dir.create(dir, showWarnings = FALSE, recursive = TRUE)
    }
    
    download <- TRUE
    if (file.exists(filename)) {
      if (api.download.count(filename, format) == facet$count) {
	message(paste("Counts in existing local copy of", facet$term, "matches API", path, "count:", facet$count))
	download <- FALSE
      }
    }
      
    if (download == TRUE) {
      message(paste("Fetching", facet$term, "[", interval, j, "/", length(facets), "] using", uri))
      
      body <- api.get(uri)
      
      if (grepl("json", format)) { 
	json <- fromJSON(body)
	body <- toJSON(json, pretty=TRUE)
      }
      message(paste("Saving", filename))
      cat(body, file=filename)
      
      if (api.download.count(filename, format) == facet$count) {
	message(paste("Counts in fresh local copy of", facet$term, "matches API", path, "count:", facet$count))
      } else {
	# noop: Need CSV count to emit proper warning
      }
    }
  }

}

# require
library(jsonlite)
library(httr)

args <- commandArgs(TRUE)

path <- args[1]
destination <- args[2]
format <- args[3]
interval <- args[4]
intervalField <- args[5]
fields <- args[6]

usage = "Usage:\nRscript[.exe] npolar-download.R {relative API path} [{destination} {format} {interval} {intervalField}]\nExample: Rscript.exe ./bin/npolar-download.R /oceanography/buoy"
if (is.na(path)) { stop(usage[1]) }

#assignInNamespace("api", api, "npolar")
api.download(path, destination=destination, format=format, interval=interval, intervalField=intervalField, fields=fields)