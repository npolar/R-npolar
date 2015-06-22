api.download.fields <- function(path) {
  fields <- ""
  if (grepl("^/tracking/svalbard-reindeer$", path)) {
    fields <- "measured,individual,latitude,longitude,platform,platform_name,altitude,activity_y,activity_x,hdop,temperature,time_to_fix,satellites,comment"
  }
  fields
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

api.download <- function(path, destination="./api.npolar.no", format="json",
   interval="month", intervalField="measured", fields=NULL, process=NULL) {

  # Lookup default fields for this API path
  if (is.null(fields)) { fields <- api.download.fields(path) }

  if (FALSE == grepl("^/", path) && FALSE == grepl("^https?://", path) ) { stop("Please provide URI or relative API path to download") }

  if (is.na(destination)) { destination <- "./api.npolar.no" }
  if (is.na(format)) { format <- "json" }
  if (is.na(intervalField)) { intervalField <- "measured" }
  if (is.na(interval)) { interval <- "month" }

  query <- paste0("?q=&format=json&variant=atom&limit=1&size-facet=99999&date-",interval,"=",intervalField,"&sort=-",intervalField)
  uri <- paste0(api.base,path,query)

  message(paste("Starting", format, "download of", path, "interval", interval, intervalField, "to", destination))
  feed <- api.get.json(uri)$feed

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
    filename <- api.download.filename(destination, path, format, interval, intervalField, facet$term)

    download <- TRUE
    if (file.exists(filename)) {
      if (api.download.count(filename, format) == facet$count) {
        message(paste("Counts in existing local copy of", facet$term, "matches API", path, "count:", facet$count))
        download <- FALSE
      }
    }
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
        message(paste("Counts in fresh local copy of", facet$term, "matches API", path, "count:", facet$count))
      } else {
        # noop: Need CSV count to emit proper warning
      }
    }
  }

}