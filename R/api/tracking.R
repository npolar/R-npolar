# Experimental/proof-of-concept tracking processor

api.tracking.processor <- function(tracks) {
  i <- 0
  message(paste("Processing", length(tracks), "documents"))

  for(i in 1:length(tracks)){

    track <- tracks[i][1]
    tracks[i] <- api.tracking.merge(track, metadata)

  }
  tracks

}

# Just a proof-of-concept function
api.tracking.merge <- function(track, metadata) {
  track[[1]]$platform_name = "platform_name"
  track[[1]]$individual = "individual"
  track
}

# Reindeer
# "/tracking/deployment/?q=&filter-species=Rangifer+tarandus+platyrhynchus&filter-provider=followit.se"