library(jsonlite)
library(httr)

api.base <- "https://api.npolar.no"

# Set username/password using the following [environmental variables]():
# R_NPOLAR_USERNAME / R_NPOLAR_PASSWORD
# Sys.setenv(R_NPOLAR_USERNAME="username")
# Sys.setenv(R_NPOLAR_PASSWORD="password")
api.security.username <- function() {
  Sys.getenv("R_NPOLAR_USERNAME")
}

api.security.password <- function() {
  invisible(Sys.getenv("R_NPOLAR_PASSWORD"))
}

api.get <- function(uri, headers) {
  username <- api.security.username()
  password <- api.security.password()

  if (FALSE == grepl("https?://", uri)) { uri <- paste0(api.base, uri) }

  response <- httr::GET(uri, authenticate(username, password, "basic"), timeout(300))
  if (response$status_code > 299) {
    stop(paste("GET request failed with status", response$status_code, "for", uri, "\n", response))
  }
  httr::content(response, "text")
}

api.get.json <- function(uri) {
  json <- api.get(uri)
  jsonlite::fromJSON(json, simplifyVector = FALSE, simplifyDataFrame = FALSE)
}

# @todo Integrity checksum using revisions (or other key found in all documents)
# Given uri for a month like
# "https://api.npolar.no/oceanography/buoy?limit=1&size-facet=99999&variant=atom&q=&format=json&date-month=measured&sort=-measured&filter-measured=2015-05-01T00:00:00Z..2015-06-01T00:00:00Z&sort=measured&limit=all&fields=id,_rev&variant=array"
# irb(main):018:0> Digest::SHA1.hexdigest JSON.parse(open(uri).read).map {|d| d["_rev"] }.join
# => "14362d57dad7f5bf473802020e1438349e049db6"
#
# @todo Add "npolar" as namespace
# http://r-pkgs.had.co.nz/namespace.html
#
# @todo Proper (installable) R-package
