# npolar-download.R 
#   Download an entire Npolar API collection to disk, sliced in one document per year, month, or day (interval)
#
# Usage:
#  Rscript npolar-download.R {relative API path} {destination} {format} {interval} {intervalField}
#
# Authentication
#   Set R_NPOLAR_USERNAME and R_NPOLAR_USERNAME (only needed if the API endpoint has restricted access)
# 
# Examples
# JSON replica of Dataset API organised by year created
#   ➜ Rscript ./bin/npolar-download.R /dataset ./api.npolar.no json year created
#
# CSV download of Svalbard Reindeer GPS tracks, with 1 document per month
#   ➜ Rscript ./bin/npolar-download.R /tracking/svalbard-reindeer /tmp/api.npolar.no csv month measured "measured,platform,latitude,longitude,altitude,activity_y,activity_x,hdop,temperature,time_to_fix,satellites,comment"
#
# Dependencies
# * [httr](https://github.com/hadley/httr)
# * [jsonlite]
#
# Notice: This is an initial draft version
api.get <- function(uri, headers) {

  username <- Sys.getenv("R_NPOLAR_USERNAME")
  password <- Sys.getenv("R_NPOLAR_PASSWORD")
  
  response <- httr::GET(uri, authenticate(username, password, "basic")) # set_cookies(), add_headers(), authenticate(), use_proxy(), verbose(), timeout(), content_type(), accept(), progress().
  if (response$status_code > 299) {
    stop(paste("GET request failed with status", response$status_code, "for", uri, "\n", response))
  }
  httr::content(response, "text")
}

api.json <- function(uri) {
  json <- api.get(uri)
  jsonlite::fromJSON(json, simplifyVector = FALSE, simplifyDataFrame = FALSE)
}

checkCount <- function(filename, format) {
  
  count <- 0
  if (grepl("csv", format)) {  
    count <- 0 # nrow(read.csv(filename))
  } else if (grepl("json", format)) {
    count <- length(fromJSON(filename, simplifyVector = FALSE, simplifyDataFrame = FALSE))
  }
  count
  
}
      
intervalFacet <- function(feed, term) {

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


library(jsonlite)
library(httr) # http://cran.r-project.org/web/packages/httr/vignettes/quickstart.html

args <- commandArgs(TRUE)

# if  != "/") == TRUE {
#   stop("Usage: Rscript npolar-fetch.R /api/path")
# }
base <- "https://api.npolar.no"

path <- args[1] # "/dataset"
destination <- args[2] # "."
format <- args[3]
interval <- args[4] # "month"
intervalField <- args[5] #"measured"
fields <- args[6] # measured,platform,latitude,longitude,altitude,activity_y,activity_x,hdop,temperature,time_to_fix,satellites,comment

usage = "Usage:\nRscript npolar-download.R {relative API path} [{destination} {format} {interval} {intervalField}]"

if (is.na(path)) { stop(usage) }
if (is.na(destination)) { destination <- "./api.npolar.no" }
if (is.na(format)) { format <- "json" }
if (is.na(intervalField)) { intervalField <- "measured" }
if (is.na(interval)) { interval <- "month" }
#if (is.na(fields)) { }

query <- paste0("?q=&format=json&variant=atom&limit=1&date-",interval,"=",intervalField,"&sort=-",intervalField)
uri <- paste0(base,path,query)

message(paste("Starting", format, "download of", path, "interval", interval, intervalField, "to", destination))
feed <- api.json(uri)$feed

message(paste(feed$opensearch$totalResults, "remote documents, most recent", intervalField, "\n", toJSON(feed$entries)))

j = 0
term <- paste0(interval, "-", intervalField)

facets = intervalFacet(feed, term)
message(paste(length(facets), interval, "intervals using", intervalField))

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
  
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  
  download <- TRUE
  if (file.exists(filename)) {
    if (checkCount(filename, format) == facet$count) {
      message(paste("Counts in local copy of", facet$term, "matches API", path, "count:", facet$count))
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
  }
}