# R-npolar
[R](http://www.r-project.org/)-package* for interacting with the [Norwegian Polar Institute's REST API](https://api.npolar.no)s.

* to-be

## api.download

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