library(jsonlite)
library(httr)

api.base <- "https://api.npolar.no"

api.security.password <- function() {
  invisible(Sys.getenv("R_NPOLAR_PASSWORD"))
}

api.security.username <- function() {
  Sys.getenv("R_NPOLAR_USERNAME")
}

api.get <- function(uri, headers) {
  username <- api.security.password()
  password <- api.security.password()

  if (FALSE == grepl("https?://", uri)) { uri <- paste0(api.base, uri) }

  response <- httr::GET(uri, authenticate(username, password, "basic"), timeout(30))
  if (response$status_code > 299) {
    stop(paste("GET request failed with status", response$status_code, "for", uri, "\n", response))
  }
  httr::content(response, "text")
}

api.get.json <- function(uri) {
  json <- api.get(uri)
  jsonlite::fromJSON(json, simplifyVector = FALSE, simplifyDataFrame = FALSE)
}

