api# npolar-download.R
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
#source ("./R/api.R")
#source ("./R/api/downlod.R")

args <- commandArgs(TRUE)

path <- args[1]
destination <- args[2]
format <- args[3]
interval <- args[4]
intervalField <- args[5]
fields <- args[6]

usage = "Usage:\nRscript[.exe] npolar-download.R {relative API path} [{destination} {format} {interval} {intervalField}]\nExample: Rscript.exe ./bin/npolar-download.R /oceanography/buoy"
if (is.na(path)) { stop(usage[1]) }

api.download(path, destination=destination, format=format, interval=interval, intervalField=intervalField, fields=fields)