api.download.fields <- function(path) {
  fields <- NULL
  if (grepl("^/tracking/svalbard-reindeer$", path)) {
    fields <- "measured,individual,latitude,longitude,platform,platform_name,altitude,activity_y,activity_x,hdop,temperature,time_to_fix,satellites,comment"
  } else if (grepl("^/tracking/svalbard-rock-ptarmigan$", path)) {
    # "_id,_rev,altitude,base,bundle,collection,created,created_by,decoder,deployed,deployment,file,headers,id,identical,individual,latitude,lc,lines,longitude,measured,message_type,object,parser,platform,platform_model,platform_type,positioned,program,satellite,sensor_data,sensor_variables,sensors,source,species,technology,temperature,terminated,type,updated,updated_by,voltage"
    fields <- "altitude,deployed,deployment,headers,identical,individual,latitude,lc,lines,longitude,measured,message_type,platform,platform_model,platform_type,positioned,program,satellite,sensor_data,sensor_variables,sensors,source,technology,temperature,terminated,type,voltage"
  }
  message(paste("Fields", fields, "for path", path))
  fields
}

api.download.count <- function(filename, format) {
  count <- 0
  if (grepl("^csv$", format)) {

    csv = read.csv(filename, sep="\t")
    count <- nrow(csv)

  } else if (grepl("^json$", format)) {

    count <- length(fromJSON(filename, simplifyVector = FALSE, simplifyDataFrame = FALSE))

  } else if (grepl("^geojson$", format)) {

    count <- length(fromJSON(filename, simplifyVector = FALSE, simplifyDataFrame = FALSE)$features)
  }
  count
}

api.download.intervalFacet <- function(feed, term) {

  vector = c()
  for(i in 1:length(feed$facets)){

    # Warning the double array feed$facets are deprecated WILL change
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

# Create filename ./api.npolar.no/dataset/json/month-created/2015-04-dataset-npolar.json
api.download.filename <- function(destination=NULL, path=NULL, format=NULL, interval=NULL, intervalField=NULL, term) {

  dir <- paste0(destination, "/", path, "/", format, "/",  interval, "-", intervalField)
  if (FALSE == file.exists(dir)) {
    dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  }
  stem <- gsub("/", "-", gsub("^/", "", path))
  filename <- paste0(dir, "/", term, "-", stem, "-", "npolar", ".", format)
}

#' Download the entire contents of a Npolar [API](https://api.npolar.no)
#'
#' This function is intended as a mirroring utility to keep a local copy in sync with a remote API.
#' It's safe and fast to run the function multiple times as only periods missing in the local copy will be downloaded.
#
#' The local mirror consists of one file per period of a given interval (1 month is the default interval).
#'
#' Operates by first retreiving all periods of data (date-faceting), and then retrievs and stores the response bodies of each period.
#'
#' Files are organised using the following folder structure: {destination}/{path}/{format}/{interval-intervalField}/,
#' e.g.: "./api.npolar.no/tracking/svalbard-reindeer/json/month-measured".
#'
#' @param path           The API path to download, e.g. "/oceanograohy/buoy"
#' @param destination    Local mirror destination (parent folder)
#' @param interval       One of: "day", "month", "year"
#' @param intervalField  The field to use for interval calculations
#' @param format         Response format: "json", "geojson", "csv"
#' @param fields         Comma separated list of fields to include, see also api.download.fields
#' @return NULL
#' @example api.download("/oceanography/buoy")
#' Starting json download of /oceanography/buoy interval month measured to ./api.npolar.no
#' 37349 remote documents, most recent measured [...]
#' Fetching 2015-01 [ month 1 / 6 ] using https://api.npolar.no/oceanography/buoy?limit=1&size-facet=99999&variant=atom&q=&format=json&date-month=measured&sort=-measured&filter-measured=2015-01-01T00:00:00Z..2015-02-01T00:00:00Z&format=json&sort=measured&limit=all&fields=&variant=array
#' Saving ./api.npolar.no//oceanography/buoy/json/month-measured/2015-01-oceanography-buoy-npolar.json
#' [...]
#' @export
api.download <- function(path, destination="./api.npolar.no", format="json",
   interval="month", intervalField="measured", fields=NULL, process=NULL) {

  # Lookup default fields for this API path
  if (is.null(fields)) { fields <- api.download.fields(path) }

  # Check that path is a relative path starting with / or a https URI
  if (FALSE == grepl("^/", path) && FALSE == grepl("^https?://", path) ) { stop("Please provide URI or relative API path to download") }

  # Force defaults
  if (is.na(destination)) { destination <- "./api.npolar.no" }
  if (is.na(format)) { format <- "json" }
  if (is.na(intervalField)) { intervalField <- "measured" }
  if (is.na(interval)) { interval <- "month" }

  # GET interval facets - and the last document
  query <- paste0("?q=&format=json&variant=atom&limit=1&size-facet=99999&date-",interval,"=",intervalField,"&sort=-",intervalField)
  uri <- paste0(api.base,path,query)

  message(paste("Starting", format, "download of", path, "interval", interval, intervalField, "to", destination))
  feed <- api.get.json(uri)$feed

  message(paste(feed$opensearch$totalResults, "remote documents"))
  #message(paste("Most recent", intervalField, ":\n", toJSON(feed$entries, pretty=TRUE, auto_unbox=TRUE)))

  j = 0
  localCount = 0;
  term <- paste0(interval, "-", intervalField)

  # Get list of periods with data (ie. interval facets)
  facets = api.download.intervalFacet(feed, term)

  message(paste("Mirroring", length(facets), interval, "periods based on the", intervalField, "field"))

  # Download each period - if the facet count != local copy count
  for (facet in facets) {

    j <- j+1

    # Download URI from facet uri (just force https)
    uri <- sub("^http", "https", facet$uri)
    uri <- paste0(uri, "&format=", format, "&sort=", intervalField, "&limit=all")

    # fields=
    if (FALSE == is.null(fields)) {

      # https://github.com/npolar/icelastic/issues/45
      if (FALSE == grepl("^csv$", format)) {
        uri <- paste0(uri, "&fields=", fields)
      }

    }

    # For JSON, but not GeoJSON, set variant=array
    if (grepl("^json$", format)) {
      uri <- paste0(uri, "&variant=", "array")
    }

    # Get filename
    filename <- api.download.filename(destination, path, format, interval, intervalField, facet$term)

    # Download?
    download <- TRUE

    # Set download to FALSE if local count == facet count
    if (file.exists(filename)) {
      if (api.download.count(filename, format) == facet$count) {
        message(paste("Existing local", format, "file for", facet$term, "matches API", path, "count:", facet$count))
        download <- FALSE
        localCount = localCount + api.download.count(filename, format)
      }
    }

    # Perform download
    if (download == TRUE) {
      message(paste("Fetching", facet$term, "[", interval, j, "/", length(facets), "] using", uri))

      if (grepl("^json$", format)) {
        json <- api.get.json(uri)

        if (FALSE == is.null(process)) {
          message(paste("Processing", filename))
          json = process(json)
        }
        body <- toJSON(json, pretty=TRUE, auto_unbox=TRUE)
      } else {
        body <- api.get(uri)
      }
      message(paste("Saving", filename))

      cat(body, file=filename)

      if (api.download.count(filename, format) == facet$count) {
        message(paste("Counts in fresh", format, "local copy of", facet$term, "matches API", path, "count:", facet$count))
        localCount = localCount + api.download.count(filename, format)

      } else {
        # noop: Need CSV count to emit proper warning
      }
    }
  }

  # Check total counts
  message(paste("Finished", format, "download"))
  if (feed$opensearch$totalResults == localCount) {
    destDir <- paste0(destination, path, "/", format, "/", interval, "-", intervalField)
    message(paste("Local mirror", destDir, "matches total count in remote API", path, ":", localCount))
  } else {
    message(paste("Mirroring failed! Local copy count:", localCount, "/ remote count:", feed$opensearch$totalResults))
  }
}