# R-npolar
[R](http://www.r-project.org/)-package(-to-be) for interacting with the [Norwegian Polar Institute's REST API](https://api.npolar.no)s.

### Getting started

```R
install.packages("jsonlite")
install.packages("httr")
source('/path/to/R-npolar/R/api.R')
source('/path/to/R-npolar/R/api/download.R') 
```

### Authentication
Set the following environmental variables in your host operating system, or in you `.Rprofile`. 

```
R_NPOLAR_USERNAME
R_NPOLAR_PASSWORD
```

### api.download
This function is a mirroring utility intended to keep a local copy in sync with a remote Npolar [API](https://api.npolar.no).
Only periods missing in the local copy will be downloaded. The local mirror consists of one file in the specified format per month. 
Supprted formats include JSON, GeoJSON, and CSV (tab-separated).

Example:
```http
> api.download("/oceanography/buoy", format="geojson")
Starting geojson download of /oceanography/buoy interval month measured to ./api.npolar.no
41601 remote documents
Mirroring 7 month periods based on the measured field
Existing local geojson file for 2015-01 matches API /oceanography/buoy count: 2171
Existing local geojson file for 2015-02 matches API /oceanography/buoy count: 6968
Existing local geojson file for 2015-03 matches API /oceanography/buoy count: 6290
Existing local geojson file for 2015-04 matches API /oceanography/buoy count: 5267
Fetching 2015-05 [ month 5 / 7 ] using https://api.npolar.no/oceanography/buoy?limit=1&size-facet=99999&variant=atom&q=&format=json&date-month=measured&sort=-measured&filter-measured=2015-05-01T00:00:00Z..2015-06-01T00:00:00Z&format=geojson&sort=measured&limit=all
Saving ./api.npolar.no//oceanography/buoy/geojson/month-measured/2015-05-oceanography-buoy-npolar.geojson
Counts in fresh geojson local copy of 2015-05 matches API /oceanography/buoy count: 12427
Fetching 2015-06 [ month 6 / 7 ] using https://api.npolar.no/oceanography/buoy?limit=1&size-facet=99999&variant=atom&q=&format=json&date-month=measured&sort=-measured&filter-measured=2015-06-01T00:00:00Z..2015-07-01T00:00:00Z&format=geojson&sort=measured&limit=all
Saving ./api.npolar.no//oceanography/buoy/geojson/month-measured/2015-06-oceanography-buoy-npolar.geojson
Counts in fresh geojson local copy of 2015-06 matches API /oceanography/buoy count: 6690
Fetching 2015-07 [ month 7 / 7 ] using https://api.npolar.no/oceanography/buoy?limit=1&size-facet=99999&variant=atom&q=&format=json&date-month=measured&sort=-measured&filter-measured=2015-07-01T00:00:00Z..2015-08-01T00:00:00Z&format=geojson&sort=measured&limit=all
Saving ./api.npolar.no//oceanography/buoy/geojson/month-measured/2015-07-oceanography-buoy-npolar.geojson
Counts in fresh geojson local copy of 2015-07 matches API /oceanography/buoy count: 1788
Finished geojson download
Local mirror ./api.npolar.no/oceanography/buoy/geojson/month-measured matches total count in remote API /oceanography/buoy : 41601
```