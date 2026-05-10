# socratadata

Explore Socrata data with ease.

`socratadata` provides an easy-to-use interface for downloading data
from [Socrata](https://dev.socrata.com/) open data portals powered by
Rust. `socratadata` improves upon the existing
[`RSocrata`](https://dev.socrata.com/connectors/rsocrata) package by
introducing support for the [Socrata Discovery
API](https://dev.socrata.com/docs/other/discovery#?route=overview) and
all [Socrata datatypes](https://dev.socrata.com/docs/datatypes/).

Unlike `RSocrata`, `socratadata` does not support uploading or editing
existing datasets.

## Installation

You can install `socratadata` from CRAN.

``` r

install.packages("socratadata")
```

You can install the development version of socratadata from
[GitHub](https://github.com/) with:

``` r

# install.packages("pak")
pak::pak("ryanzomorrodi/socratadata")
```

## Usage

### Search for datasets

Use
[`soc_discover()`](https://ryanzomorrodi.github.io/socratadata/reference/soc_discover.md)
to explore the datasets with a domain.

``` r

library(socratadata)

soc_discover(domains = "data.cityofchicago.org")
#> # A tibble: 907 × 30
#>    id        parent_ids name          attribution attribution_link contact_email
#>  * <chr>     <list>     <chr>         <chr>       <chr>            <chr>        
#>  1 ydr8-5enu <chr [0]>  Building Per… City of Ch… http://www.city… <NA>         
#>  2 xzkq-xp2w <chr [0]>  Current Empl… City of Ch… http://www.chic… <NA>         
#>  3 ijzp-q8t2 <chr [0]>  Crimes - 200… Chicago Po… https://www.chi… <NA>         
#>  4 85ca-t3if <chr [0]>  Traffic Cras… City of Ch… http://www.chic… <NA>         
#>  5 4ijn-s7e5 <chr [0]>  Food Inspect… City of Ch… http://www.city… <NA>         
#>  6 s6ha-ppgi <chr [0]>  Affordable R… City of Ch… http://www.city… <NA>         
#>  7 2ft4-4uik <chr [0]>  Lobbyist Dat… City of Ch… http://www.city… <NA>         
#>  8 i6bp-fvbx <chr [0]>  Chicago Stre… City of Ch… http://www.city… <NA>         
#>  9 kn9c-c2s2 <chr [0]>  Census Data … U.S. Censu… http://factfind… <NA>         
#> 10 r5kz-chrr <chr [0]>  Business Lic… City of Ch… http://www.city… <NA>         
#> # ℹ 897 more rows
#> # ℹ 24 more variables: resource_type <chr>, owner <tibble[,2]>,
#> #   creator <tibble[,2]>, provenance <chr>, description <chr>, created <dttm>,
#> #   updated <dttm>, published <dttm>, data_last_updated <dttm>,
#> #   metadata_last_updated <dttm>, categories <list>, tags <list>,
#> #   domain_categories <chr>, domain_tags <list>, domain_metadata <list>,
#> #   columns <list>, permalink <chr>, link <chr>, domain <chr>, license <chr>, …
```

Or with a query.

``` r

soc_discover(query = "bus")
#> # A tibble: 881 × 30
#>    id        parent_ids name          attribution attribution_link contact_email
#>  * <chr>     <list>     <chr>         <chr>       <chr>            <chr>        
#>  1 ez4e-fazm <chr [0]>  Bus Breakdow… Department… <NA>             <NA>         
#>  2 bzwk-3hb4 <chr [0]>  MTA Bus Rout… Metropolit… https://www.mta… <NA>         
#>  3 6qat-uaei <chr [0]>  DART Bus Sch… Department… http://www.dart… <NA>         
#>  4 eqmj-6b8d <chr [0]>  Bronx Bus St… mta.info    http://mta.info… <NA>         
#>  5 2ucp-7wg5 <chr [0]>  MTA Bus Stops Metropolit… https://www.mta… <NA>         
#>  6 ycrg-ses3 <chr [0]>  Bus Lanes - … Department… <NA>             <NA>         
#>  7 bd2s-bfst <chr [0]>  KCATA Bus St… KCATA Tran… http://www.kcat… <NA>         
#>  8 6uva-a5ei <chr [0]>  CTA - Bus Ro… City of Ch… http://www.tran… <NA>         
#>  9 nmjv-498y <chr [0]>  Bus Ridership Transit Se… <NA>             <NA>         
#> 10 ifm8-78yv <chr [0]>  Bus Routes    Transport … <NA>             <NA>         
#> # ℹ 871 more rows
#> # ℹ 24 more variables: resource_type <chr>, owner <tibble[,2]>,
#> #   creator <tibble[,2]>, provenance <chr>, description <chr>, created <dttm>,
#> #   updated <dttm>, published <dttm>, data_last_updated <dttm>,
#> #   metadata_last_updated <dttm>, categories <list>, tags <list>,
#> #   domain_categories <chr>, domain_tags <list>, domain_metadata <list>,
#> #   columns <list>, permalink <chr>, link <chr>, domain <chr>, license <chr>, …
```

Or with categories.

``` r

soc_discover(categories = "transportation")
#> # A tibble: 406 × 30
#>    id        parent_ids name          attribution attribution_link contact_email
#>  * <chr>     <list>     <chr>         <chr>       <chr>            <chr>        
#>  1 2tq4-9mfn <chr [0]>  Vital Signs:… Federal Tr… http://www.ntdp… <NA>         
#>  2 pksj-2mmj <chr [0]>  Vital Signs:… Federal Tr… http://www.ntdp… <NA>         
#>  3 f57x-8ifw <chr [0]>  Vital Signs:… <NA>        <NA>             <NA>         
#>  4 wdpr-f2dr <chr [0]>  Vital Signs:… Federal Tr… http://www.ntdp… <NA>         
#>  5 ei2q-6g8n <chr [0]>  Parking Cita… Division o… https://www.nor… <NA>         
#>  6 muzh-c9qc <chr [0]>  Calgary Tran… The City o… <NA>             <NA>         
#>  7 btc8-9kef <chr [0]>  Citizen Sati… The City o… https://calgary… <NA>         
#>  8 cwsm-2ns3 <chr [0]>  Quarterly Ce… New York S… http://www.labo… <NA>         
#>  9 7y2e-49j8 <chr [0]>  Weigh-In-Mot… New York S… https://www.dot… <NA>         
#> 10 w96p-f2qv <chr [0]>  Daily Mobili… Maryland T… https://mti.umd… kyle.titlow@…
#> # ℹ 396 more rows
#> # ℹ 24 more variables: resource_type <chr>, owner <tibble[,2]>,
#> #   creator <tibble[,2]>, provenance <chr>, description <chr>, created <dttm>,
#> #   updated <dttm>, published <dttm>, data_last_updated <dttm>,
#> #   metadata_last_updated <dttm>, categories <list>, tags <list>,
#> #   domain_categories <chr>, domain_tags <list>, domain_metadata <list>,
#> #   columns <list>, permalink <chr>, link <chr>, domain <chr>, license <chr>, …

soc_discover(
  domains = "data.cityofchicago.org",
  domain_category = "Transportation"
)
#> # A tibble: 87 × 30
#>    id        parent_ids name          attribution attribution_link contact_email
#>  * <chr>     <list>     <chr>         <chr>       <chr>            <chr>        
#>  1 85ca-t3if <chr [0]>  Traffic Cras… City of Ch… http://www.chic… <NA>         
#>  2 i6bp-fvbx <chr [0]>  Chicago Stre… City of Ch… http://www.city… <NA>         
#>  3 ygr5-vcbg <chr [0]>  Towed Vehicl… Chicago Po… http://www.chic… <NA>         
#>  4 6iiy-9s97 <chr [0]>  CTA - Riders… Chicago Tr… http://www.tran… <NA>         
#>  5 u6pd-qa9d <chr [0]>  Traffic Cras… City of Ch… http://www.chic… <NA>         
#>  6 spqx-js37 <chr [0]>  Red Light Ca… City of Ch… http://www.city… <NA>         
#>  7 m6dm-c72p <chr [0]>  Transportati… City of Ch… https://www.chi… <NA>         
#>  8 kf7e-cur8 <chr [0]>  Chicago Traf… City of Ch… https://www.chi… <NA>         
#>  9 pnau-cf66 <chr [0]>  CTA - List o… Chicago Tr… http://www.tran… <NA>         
#> 10 sxs8-h27x <chr [0]>  Chicago Traf… City of Ch… https://www.cit… <NA>         
#> # ℹ 77 more rows
#> # ℹ 24 more variables: resource_type <chr>, owner <tibble[,2]>,
#> #   creator <tibble[,2]>, provenance <chr>, description <chr>, created <dttm>,
#> #   updated <dttm>, published <dttm>, data_last_updated <dttm>,
#> #   metadata_last_updated <dttm>, categories <list>, tags <list>,
#> #   domain_categories <chr>, domain_tags <list>, domain_metadata <list>,
#> #   columns <list>, permalink <chr>, link <chr>, domain <chr>, license <chr>, …
```

Or with tags.

``` r

soc_discover(
  domains = "data.cityofchicago.org",
  domain_tags = "public transit"
)
#> # A tibble: 12 × 30
#>    id        parent_ids name          attribution attribution_link contact_email
#>  * <chr>     <list>     <chr>         <chr>       <chr>            <chr>        
#>  1 6iiy-9s97 <chr [0]>  CTA - Riders… Chicago Tr… http://www.tran… <NA>         
#>  2 pnau-cf66 <chr [0]>  CTA - List o… Chicago Tr… http://www.tran… <NA>         
#>  3 5neh-572f <chr [0]>  CTA - Riders… Chicago Tr… http://www.tran… <NA>         
#>  4 t2rn-p8d7 <chr [0]>  CTA - Riders… Chicago Tr… http://www.tran… <NA>         
#>  5 w8km-9pzd <chr [0]>  CTA - Riders… Chicago Tr… http://www.tran… <NA>         
#>  6 bynn-gwxy <chr [0]>  CTA - Riders… Chicago Tr… http://www.tran… <NA>         
#>  7 jyb9-n7fm <chr [0]>  CTA - Riders… Chicago Tr… http://www.tran… <NA>         
#>  8 8pix-ypme <chr [0]>  CTA - System… Chicago Tr… http://www.tran… <NA>         
#>  9 mq3i-nnqe <chr [0]>  CTA - Riders… Chicago Tr… http://www.tran… <NA>         
#> 10 6uva-a5ei <chr [0]>  CTA - Bus Ro… City of Ch… http://www.tran… <NA>         
#> 11 xbyr-jnvx <chr [0]>  CTA - 'L' (R… City of Ch… http://www.tran… <NA>         
#> 12 3tzw-cg4m <chr [0]>  CTA - 'L' (R… City of Ch… http://www.tran… <NA>         
#> # ℹ 24 more variables: resource_type <chr>, owner <tibble[,2]>,
#> #   creator <tibble[,2]>, provenance <chr>, description <chr>, created <dttm>,
#> #   updated <dttm>, published <dttm>, data_last_updated <dttm>,
#> #   metadata_last_updated <dttm>, categories <list>, tags <list>,
#> #   domain_categories <chr>, domain_tags <list>, domain_metadata <list>,
#> #   columns <list>, permalink <chr>, link <chr>, domain <chr>, license <chr>,
#> #   page_views_last_week <dbl>, page_views_last_month <dbl>, …
```

Or with ids.

``` r

soc_discover(ids = c("6iiy-9s97", "pnau-cf66"))
#> # A tibble: 2 × 30
#>   id        parent_ids name           attribution attribution_link contact_email
#> * <chr>     <list>     <chr>          <chr>       <chr>            <chr>        
#> 1 6iiy-9s97 <chr [0]>  CTA - Ridersh… Chicago Tr… http://www.tran… <NA>         
#> 2 pnau-cf66 <chr [0]>  CTA - List of… Chicago Tr… http://www.tran… <NA>         
#> # ℹ 24 more variables: resource_type <chr>, owner <tibble[,2]>,
#> #   creator <tibble[,2]>, provenance <chr>, description <chr>, created <dttm>,
#> #   updated <dttm>, published <dttm>, data_last_updated <dttm>,
#> #   metadata_last_updated <dttm>, categories <list>, tags <list>,
#> #   domain_categories <chr>, domain_tags <list>, domain_metadata <list>,
#> #   columns <list>, permalink <chr>, link <chr>, domain <chr>, license <chr>,
#> #   page_views_last_week <dbl>, page_views_last_month <dbl>, …
```

### Download data

`socratadata` supports unauthenticated requests via the v2.1 API. It is,
however, recommended that you [obtain an api
key](https://support.socrata.com/hc/en-us/articles/210138558-Generating-App-Tokens-and-API-Keys)
to make your code more future-proof.
[`soc_read()`](https://ryanzomorrodi.github.io/socratadata/reference/soc_read.md)
will automatically authenticate with the `"soc_api_key_id"` and
`"soc_api_key_secret"` environment variables.

You can create an `.Renviron` file and add your keys to it like so:

``` txt
soc_api_key_id="your_id_here"
soc_api_key_secret="your_secret_here"
```

And retrieve those keys using

``` r

Sys.getenv("soc_api_key_id")
#> [1] "your_id_here"
Sys.getenv("soc_api_key_secret")
#> [1] "your_secret_here"
```

Use
[`soc_read()`](https://ryanzomorrodi.github.io/socratadata/reference/soc_read.md)
to read a socrata dataset into R.

``` r

soc_read(
  "https://data.cityofchicago.org/Transportation/CTA-Ridership-Daily-Boarding-Totals/6iiy-9s97/about_data"
)
#> # A tibble: 9,190 × 9
#>    service_date        day_type    bus rail_boardings total_rides `:id`         
#>    <dttm>              <chr>     <dbl>          <dbl>       <dbl> <chr>         
#>  1 2001-01-01 00:00:00 U        297192         126455      423647 row-pux9_24p6…
#>  2 2001-01-02 00:00:00 W        780827         501952     1282779 row-ekyk_7mqh…
#>  3 2001-01-03 00:00:00 W        824923         536432     1361355 row-7knw-h4az…
#>  4 2001-01-04 00:00:00 W        870021         550011     1420032 row-xnam~m72f…
#>  5 2001-01-05 00:00:00 W        890426         557917     1448343 row-7pqj-uxkc…
#>  6 2001-01-06 00:00:00 A        577401         255356      832757 row-kvuw~shzc…
#>  7 2001-01-07 00:00:00 U        375831         169825      545656 row-3f5d.axqe…
#>  8 2001-01-08 00:00:00 W        985221         590706     1575927 row-mxrr.356r…
#>  9 2001-01-09 00:00:00 W        978377         599905     1578282 row-i9ii.759a…
#> 10 2001-01-10 00:00:00 W        984884         602052     1586936 row-fedk_g2kd…
#> # ℹ 9,180 more rows
#> # ℹ 3 more variables: `:version` <chr>, `:created_at` <dttm>,
#> #   `:updated_at` <dttm>
```

Spatial data will be read as an `sf` object.

``` r

soc_read(
  "https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas/igwz-8jzy/about_data"
)
#> Simple feature collection with 77 features and 9 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -87.94011 ymin: 41.64454 xmax: -87.52414 ymax: 42.02304
#> Geodetic CRS:  WGS 84
#> # A tibble: 77 × 10
#>                              the_geom area_numbe community area_num_1 shape_area
#>  *                 <MULTIPOLYGON [°]>      <dbl> <chr>     <chr>           <dbl>
#>  1 (((-87.65456 41.99817, -87.65574 …          1 ROGERS P… 1           51259902.
#>  2 (((-87.68465 42.01948, -87.68464 …          2 WEST RID… 2           98429095.
#>  3 (((-87.64102 41.9548, -87.644 41.…          3 UPTOWN    3           65095643.
#>  4 (((-87.67441 41.9761, -87.6744 41…          4 LINCOLN … 4           71352328.
#>  5 (((-87.67336 41.93234, -87.67342 …          5 NORTH CE… 5           57054168.
#>  6 (((-87.64102 41.9548, -87.64101 4…          6 LAKE VIEW 6           87214799.
#>  7 (((-87.63182 41.93258, -87.63182 …          7 LINCOLN … 7           88316400.
#>  8 (((-87.62446 41.91157, -87.62459 …          8 NEAR NOR… 8           76675896.
#>  9 (((-87.80676 42.00084, -87.80676 …          9 EDISON P… 9           31636314.
#> 10 (((-87.78002 41.99741, -87.78049 …         10 NORWOOD … 10         121959105.
#> # ℹ 67 more rows
#> # ℹ 5 more variables: shape_len <dbl>, `:id` <chr>, `:version` <chr>,
#> #   `:created_at` <dttm>, `:updated_at` <dttm>
```

You can even perform complex queries using [Socrata Query Language
(SoQL)](https://dev.socrata.com/docs/queries/) via
[`soc_query()`](https://ryanzomorrodi.github.io/socratadata/reference/soc_query.md).

``` r

lower_west_side <- soc_read(
  "https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas/igwz-8jzy/about_data",
  query = soc_query(
    where = "community LIKE 'LOWER WEST SIDE'"
  )
)
print(lower_west_side)
#> Simple feature collection with 1 feature and 9 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -87.68807 ymin: 41.8348 xmax: -87.63516 ymax: 41.86002
#> Geodetic CRS:  WGS 84
#> # A tibble: 1 × 10
#>                    the_geom area_numbe community area_num_1 shape_area shape_len
#> *        <MULTIPOLYGON [°]>      <dbl> <chr>     <chr>           <dbl>     <dbl>
#> 1 (((-87.63516 41.85772, -…         31 LOWER WE… 31          81550724.    43229.
#> # ℹ 4 more variables: `:id` <chr>, `:version` <chr>, `:created_at` <dttm>,
#> #   `:updated_at` <dttm>

cta_ridership <- soc_read(
  "https://data.cityofchicago.org/Transportation/Taxi-Trips-2013-2023-/wrvz-psew/about_data",
  query = soc_query(
    select = "pickup_community_area, count(*) as n",
    where = glue::glue(
      "within_polygon(dropoff_centroid_location, '{sf::st_as_text(lower_west_side$the_geom)}')"
    ),
    group_by = "pickup_community_area",
    order_by = "n DESC"
  )
)
print(cta_ridership)
#> # A tibble: 78 × 2
#>    pickup_community_area      n
#>                    <dbl>  <dbl>
#>  1                    32 127474
#>  2                     8 113797
#>  3                    28  90983
#>  4                    31  39509
#>  5                    24  37789
#>  6                    33  22793
#>  7                    76  18006
#>  8                     6  15160
#>  9                    56  14142
#> 10                     7  12191
#> # ℹ 68 more rows
```

### Extract metadata

Access a dataset’s metadata using
[`soc_metadata()`](https://ryanzomorrodi.github.io/socratadata/reference/soc_metadata.md).

``` r

soc_metadata(cta_ridership)
#> ID: wrvz-psew
#> Attribution: City of Chicago
#> Attribution Link: https://www.chicago.gov
#> Resource Type: dataset
#> Owner ID: vewm-vupz
#> Owner Display Name: Jonathan Levy
#> Provenance: official
#> Description: <b>This dataset ends with 2023. Please see the Featured Content link below for the dataset that starts in 2024.</b>
#> 
#> Taxi trips from 2013 to 2023 reported to the City of Chicago in its role as a regulatory agency.  To protect privacy but allow for aggregate analyses, the Taxi ID is consistent for any given taxi medallion number but does not show the number, Census Tracts are suppressed in some cases, and times are rounded to the nearest 15 minutes.
#> 
#> Due to the data reporting process, not all trips are reported but the City believes that most are.
#> Created: 2016-05-27 21:27:48
#> Published: 2016-11-14 17:40:03
#> Data Last Updated: 2024-02-07 20:40:12
#> Metadata Last Updated: 2026-03-19 18:55:14
#> Domain Category: Transportation
#> Domain Tags: 
#> • taxis
#> • transportation
#> • historical
#> Domain Metadata: 
#> • Changes and Other Historical Information Useful to Understanding This Dataset: https://www.google.com/search?q=site:data.cityofchicago.org/stories+"Related+dataset+ID+s"+"wrvz-psew"
#> • Data Owner: Department of Business Affairs & Consumer Protection
#> • Time Period: 2013 - 2023
#> Columns: 
#> # A tibble: 24 × 4
#>    name                   label                  description            datatype
#>  * <chr>                  <chr>                  <chr>                  <chr>   
#>  1 trip_id                Trip ID                A unique identifier f… text    
#>  2 taxi_id                Taxi ID                A unique identifier f… text    
#>  3 trip_start_timestamp   Trip Start Timestamp   When the trip started… calenda…
#>  4 trip_end_timestamp     Trip End Timestamp     When the trip ended, … calenda…
#>  5 trip_seconds           Trip Seconds           Time of the trip in s… number  
#>  6 trip_miles             Trip Miles             Distance of the trip … number  
#>  7 pickup_census_tract    Pickup Census Tract    The Census Tract wher… text    
#>  8 dropoff_census_tract   Dropoff Census Tract   The Census Tract wher… text    
#>  9 pickup_community_area  Pickup Community Area  The Community Area wh… number  
#> 10 dropoff_community_area Dropoff Community Area The Community Area wh… number  
#> # ℹ 14 more rows
#> Permalink: https://data.cityofchicago.org/d/wrvz-psew
#> License: See Terms of Use
```

Or explore a dataset’s metadata using it’s url.

``` r

soc_metadata(
  "https://data.cityofchicago.org/Transportation/CTA-Ridership-Daily-Boarding-Totals/6iiy-9s97/about_data"
)
#> ID: 6iiy-9s97
#> Attribution: Chicago Transit Authority
#> Attribution Link: http://www.transitchicago.com
#> Resource Type: dataset
#> Owner ID: 6bsn-5494
#> Owner Display Name: CTA
#> Provenance: official
#> Description: This dataset shows systemwide boardings for both bus and rail services provided by CTA, dating back to 2001. Daytypes are as follows: W = Weekday, A = Saturday, U = Sunday/Holiday. See attached readme file for information on how these numbers are calculated.
#> Created: 2011-08-12 15:40:31
#> Published: 2025-04-29 16:35:04
#> Data Last Updated: 2026-04-17 21:29:45
#> Metadata Last Updated: 2026-04-17 21:29:44
#> Domain Category: Transportation
#> Domain Tags: 
#> • cta
#> • public transit
#> • ridership
#> Domain Metadata: 
#> • Changes and Other Historical Information Useful to Understanding This Dataset: https://www.google.com/search?q=site:data.cityofchicago.org/stories+"Related+dataset+ID+s"+"6iiy-9s97"
#> • Time Period: 2001 - Current
#> • Data Owner: Chicago Transit Authority 
#> Columns: 
#> # A tibble: 5 × 4
#>   name           label          description datatype     
#> * <chr>          <chr>          <chr>       <chr>        
#> 1 service_date   service_date   ""          calendar_date
#> 2 day_type       day_type       ""          text         
#> 3 bus            bus            ""          number       
#> 4 rail_boardings rail_boardings ""          number       
#> 5 total_rides    total_rides    ""          number       
#> Permalink: https://data.cityofchicago.org/d/6iiy-9s97
#> License: See Terms of Use
```
