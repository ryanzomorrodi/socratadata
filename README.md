
<!-- README.md is generated from README.Rmd. Please edit that file -->

# socratadata

<!-- badges: start -->

<!-- badges: end -->

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

Use `soc_discover()` to explore the datasets with a domain.

``` r
library(socratadata)

soc_discover(domains = "data.cityofchicago.org")
#> # A tibble: 880 × 21
#>    id    name  attribution owner_name provenance description created            
#>    <chr> <chr> <chr>       <chr>      <chr>      <chr>       <dttm>             
#>  1 xzkq… Curr… City of Ch… cocadmin   official   "This data… 2011-09-27 00:00:00
#>  2 ijzp… Crim… Chicago Po… cocadmin   official   "This data… 2011-09-30 00:00:00
#>  3 ydr8… Buil… City of Ch… cocadmin   official   "This data… 2011-09-30 00:00:00
#>  4 85ca… Traf… City of Ch… Jonathan … official   "Crash dat… 2017-10-19 00:00:00
#>  5 s6ha… Affo… City of Ch… cocadmin   official   "The renta… 2013-03-14 00:00:00
#>  6 4ijn… Food… City of Ch… cocadmin   official   "This info… 2011-08-08 00:00:00
#>  7 2ft4… Lobb… City of Ch… cocadmin   official   "All lobby… 2011-06-07 00:00:00
#>  8 i6bp… Chic… City of Ch… cocadmin   official   "List of a… 2010-12-22 00:00:00
#>  9 kn9c… Cens… U.S. Censu… Jamyia     official   "This data… 2012-01-05 00:00:00
#> 10 z8bn… Poli… Chicago Po… cocadmin   official   "Chicago P… 2010-12-22 00:00:00
#> # ℹ 870 more rows
#> # ℹ 14 more variables: data_last_updated <dttm>, metadata_last_updated <dttm>,
#> #   categories <list>, tags <list>, domain_category <chr>, domain_tags <list>,
#> #   domain_metadata <list>, column_names <list>, column_labels <list>,
#> #   column_datatypes <list>, column_descriptions <list>, permalink <chr>,
#> #   link <chr>, license <chr>
```

Or with a query.

``` r
soc_discover(query = "bus")
#> # A tibble: 876 × 21
#>    id    name  attribution owner_name provenance description created            
#>    <chr> <chr> <chr>       <chr>      <chr>      <chr>       <dttm>             
#>  1 ez4e… Bus … Department… NYC OpenD… official   "The Bus B… 2015-09-30 00:00:00
#>  2 bd2s… KCAT… KCATA Tran… DataKC     official   "This data… 2013-04-23 00:00:00
#>  3 6qat… DART… Department… Delaware … official   "This cont… 2017-07-28 00:00:00
#>  4 ycrg… Bus … Department… NYC OpenD… official   "Bus lanes… 2020-12-04 00:00:00
#>  5 s5c7… Bus … <NA>        Karl Suey… official   ""          2015-05-23 00:00:00
#>  6 eqmj… Bron… mta.info    Elkin      official   "Bronx Tra… 2012-10-06 00:00:00
#>  7 wgnh… Capi… Capital Di… NY Open D… official   "Bus stops… 2013-05-22 00:00:00
#>  8 nmjv… Bus … Transit Se… City of M… official   "***NOTE: … 2019-06-03 00:00:00
#>  9 cudb… MTA … Metropolit… NY Open D… official   "Bus Speed… 2021-12-29 00:00:00
#> 10 6uva… CTA … City of Ch… Jonathan … official   "Lines rep… 2024-07-31 00:00:00
#> # ℹ 866 more rows
#> # ℹ 14 more variables: data_last_updated <dttm>, metadata_last_updated <dttm>,
#> #   categories <list>, tags <list>, domain_category <chr>, domain_tags <list>,
#> #   domain_metadata <list>, column_names <list>, column_labels <list>,
#> #   column_datatypes <list>, column_descriptions <list>, permalink <chr>,
#> #   link <chr>, license <chr>
```

Or with categories.

``` r
soc_discover(categories = "transportation")
#> # A tibble: 457 × 21
#>    id    name  attribution owner_name provenance description created            
#>    <chr> <chr> <chr>       <chr>      <chr>      <chr>       <dttm>             
#>  1 pksj… Vita… Federal Tr… Raleigh M… official   "VITAL SIG… 2017-05-24 00:00:00
#>  2 f57x… Vita… <NA>        Raleigh M… official   "VITAL SIG… 2018-08-20 00:00:00
#>  3 2tq4… Vita… Federal Tr… Raleigh M… official   "VITAL SIG… 2017-05-22 00:00:00
#>  4 9mau… Vita… U.S. Censu… Raleigh M… official   "VITAL SIG… 2020-04-09 00:00:00
#>  5 cwsm… Quar… New York S… NY Open D… official   "The Quart… 2013-02-15 00:00:00
#>  6 muzh… Calg… The City o… Calgary O… official   "Calgary T… 2018-09-07 00:00:00
#>  7 btc8… Citi… The City o… Calgary O… official   "These are… 2021-06-10 00:00:00
#>  8 7y2e… Weig… New York S… NY Open D… official   "This data… 2015-01-21 00:00:00
#>  9 ei2q… Park… Division o… City of N… official   "This data… 2018-09-20 00:00:00
#> 10 w96p… Dail… Maryland T… Titlow, K… official   "The Daily… 2020-05-19 00:00:00
#> # ℹ 447 more rows
#> # ℹ 14 more variables: data_last_updated <dttm>, metadata_last_updated <dttm>,
#> #   categories <list>, tags <list>, domain_category <chr>, domain_tags <list>,
#> #   domain_metadata <list>, column_names <list>, column_labels <list>,
#> #   column_datatypes <list>, column_descriptions <list>, permalink <chr>,
#> #   link <chr>, license <chr>

soc_discover(
  domains = "data.cityofchicago.org",
  domain_category = "Transportation"
)
#> # A tibble: 86 × 21
#>    id    name  attribution owner_name provenance description created            
#>    <chr> <chr> <chr>       <chr>      <chr>      <chr>       <dttm>             
#>  1 85ca… Traf… City of Ch… Jonathan … official   "Crash dat… 2017-10-19 00:00:00
#>  2 i6bp… Chic… City of Ch… cocadmin   official   "List of a… 2010-12-22 00:00:00
#>  3 ygr5… Towe… Chicago Po… cocadmin   official   "This data… 2011-09-30 00:00:00
#>  4 5k2z… Relo… City of Ch… cocadmin   official   "This data… 2011-09-30 00:00:00
#>  5 m6dm… Tran… City of Ch… Jonathan … official   "<b>This d… 2018-10-02 00:00:00
#>  6 6iiy… CTA … Chicago Tr… CTA        official   "This data… 2011-08-12 00:00:00
#>  7 68nd… Traf… City of Ch… Jonathan … official   "This data… 2018-01-04 00:00:00
#>  8 n4j6… Chic… City of Ch… cocadmin   official   "This data… 2011-11-20 00:00:00
#>  9 4i42… Spee… City of Ch… cocadmin   official   "This data… 2014-08-11 00:00:00
#> 10 hhkd… Spee… City of Ch… cocadmin   official   "This data… 2014-08-08 00:00:00
#> # ℹ 76 more rows
#> # ℹ 14 more variables: data_last_updated <dttm>, metadata_last_updated <dttm>,
#> #   categories <list>, tags <list>, domain_category <chr>, domain_tags <list>,
#> #   domain_metadata <list>, column_names <list>, column_labels <list>,
#> #   column_datatypes <list>, column_descriptions <list>, permalink <chr>,
#> #   link <chr>, license <chr>
```

Or with tags.

``` r
soc_discover(
  domains = "data.cityofchicago.org",
  domain_tags = "public transit"
)
#> # A tibble: 12 × 21
#>    id    name  attribution owner_name provenance description created            
#>    <chr> <chr> <chr>       <chr>      <chr>      <chr>       <dttm>             
#>  1 6iiy… CTA … Chicago Tr… CTA        official   "This data… 2011-08-12 00:00:00
#>  2 pnau… CTA … Chicago Tr… CTA        official   "This list… 2011-08-12 00:00:00
#>  3 t2rn… CTA … Chicago Tr… CTA        official   "This data… 2011-08-05 00:00:00
#>  4 5neh… CTA … Chicago Tr… CTA        official   "This list… 2011-08-05 00:00:00
#>  5 8pix… CTA … Chicago Tr… CTA        official   "This list… 2011-08-04 00:00:00
#>  6 bynn… CTA … Chicago Tr… CTA        official   "This data… 2011-08-05 00:00:00
#>  7 w8km… CTA … Chicago Tr… CTA        official   "This data… 2011-08-11 00:00:00
#>  8 mq3i… CTA … Chicago Tr… CTA        official   "This data… 2011-08-11 00:00:00
#>  9 jyb9… CTA … Chicago Tr… CTA        official   "This data… 2011-08-05 00:00:00
#> 10 6uva… CTA … City of Ch… Jonathan … official   "Lines rep… 2024-07-31 00:00:00
#> 11 xbyr… CTA … City of Ch… Jonathan … official   "Lines rep… 2024-07-12 00:00:00
#> 12 3tzw… CTA … City of Ch… Jonathan … official   "Points re… 2024-08-09 00:00:00
#> # ℹ 14 more variables: data_last_updated <dttm>, metadata_last_updated <dttm>,
#> #   categories <list>, tags <list>, domain_category <chr>, domain_tags <list>,
#> #   domain_metadata <list>, column_names <list>, column_labels <list>,
#> #   column_datatypes <list>, column_descriptions <list>, permalink <chr>,
#> #   link <chr>, license <chr>
```

Or with ids.

``` r
soc_discover(ids = c("6iiy-9s97", "pnau-cf66"))
#> # A tibble: 2 × 21
#>   id     name  attribution owner_name provenance description created            
#>   <chr>  <chr> <chr>       <chr>      <chr>      <chr>       <dttm>             
#> 1 6iiy-… CTA … Chicago Tr… CTA        official   This datas… 2011-08-12 00:00:00
#> 2 pnau-… CTA … Chicago Tr… CTA        official   This lists… 2011-08-12 00:00:00
#> # ℹ 14 more variables: data_last_updated <dttm>, metadata_last_updated <dttm>,
#> #   categories <list>, tags <list>, domain_category <chr>, domain_tags <list>,
#> #   domain_metadata <list>, column_names <list>, column_labels <list>,
#> #   column_datatypes <list>, column_descriptions <list>, permalink <chr>,
#> #   link <chr>, license <chr>
```

### Download data

`socratadata` supports unauthenticated requests via the v2.1 API. It is,
however, recommended that you [obtain an api
key](https://support.socrata.com/hc/en-us/articles/210138558-Generating-App-Tokens-and-API-Keys)
to make your code more future-proof. `soc_read()` will automatically
authenticate with the `"soc_api_key_id"` and `"soc_api_key_secret"`
environment variables.

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

Use `soc_read()` to read a socrata dataset into R.

``` r
soc_read(
  "https://data.cityofchicago.org/Transportation/CTA-Ridership-Daily-Boarding-Totals/6iiy-9s97/about_data"
)
#> # A tibble: 8,886 × 9
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
#> # ℹ 8,876 more rows
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
(SoQL)](https://dev.socrata.com/docs/queries/) via `soc_query()`.

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

Access a dataset’s metadata using `soc_metadata()`.

``` r
soc_metadata(cta_ridership)
#> ID: wrvz-psew
#> Name: Taxi Trips (2013-2023)
#> Attribution: City of Chicago
#> Owner: Jonathan Levy
#> Provenance: official
#> Description: <b>This dataset ends with 2023. Please see the Featured Content
#> link below for the dataset that starts in 2024.</b> Taxi trips from 2013 to
#> 2023 reported to the City of Chicago in its role as a regulatory agency.  To
#> protect privacy but allow for aggregate analyses, the Taxi ID is consistent for
#> any given taxi medallion number but does not show the number, Census Tracts are
#> suppressed in some cases, and times are rounded to the nearest 15 minutes. Due
#> to the data reporting process, not all trips are reported but the City believes
#> that most are.
#> Created: 2016-05-27 21:27:48
#> Data last updated: 2024-02-07 20:40:12
#> Metadata last Updated: 2024-06-21 17:06:18
#> Domain Category: Transportation
#> Domain Tags: taxis, transportation, and historical
#> Domain fields:
#> • Time Period: 2013 - 2023
#> • Changes and Other Historical Information Useful to Understanding This
#> Dataset:
#> https://www.google.com/search?as_q="Related+dataset+ID+s"+"wrvz-psew"+inurl:stories&as_sitesearch=data.cityofchicago.org
#> • Data Owner: Department of Business Affairs & Consumer Protection
#> Columns:
#> # A tibble: 24 × 4
#>    column_name               column_label     column_datatype column_description
#>    <chr>                     <chr>            <chr>           <chr>             
#>  1 trip_id                   Trip ID          text            A unique identifi…
#>  2 taxi_id                   Taxi ID          text            A unique identifi…
#>  3 trip_start_timestamp      Trip Start Time… calendar_date   When the trip sta…
#>  4 trip_end_timestamp        Trip End Timest… calendar_date   When the trip end…
#>  5 trip_seconds              Trip Seconds     number          Time of the trip …
#>  6 trip_miles                Trip Miles       number          Distance of the t…
#>  7 pickup_census_tract       Pickup Census T… text            The Census Tract …
#>  8 dropoff_census_tract      Dropoff Census … text            The Census Tract …
#>  9 pickup_community_area     Pickup Communit… number          The Community Are…
#> 10 dropoff_community_area    Dropoff Communi… number          The Community Are…
#> 11 fare                      Fare             number          The fare for the …
#> 12 tips                      Tips             number          The tip for the t…
#> 13 tolls                     Tolls            number          The tolls for the…
#> 14 extras                    Extras           number          Extra charges for…
#> 15 trip_total                Trip Total       number          Total cost of the…
#> 16 payment_type              Payment Type     text            Type of payment f…
#> 17 company                   Company          text            The taxi company. 
#> 18 pickup_centroid_latitude  Pickup Centroid… number          The latitude of t…
#> 19 pickup_centroid_longitude Pickup Centroid… number          The longitude of …
#> 20 pickup_centroid_location  Pickup Centroid… point           The location of t…
#> # ℹ 4 more rows
#> Permalink: https://data.cityofchicago.org/d/wrvz-psew
#> Link:
#> https://data.cityofchicago.org/Transportation/Taxi-Trips-2013-2023-/wrvz-psew
#> License: See Terms of Use
```

Or explore a dataset’s metadata using it’s url.

``` r
soc_metadata(
  "https://data.cityofchicago.org/Transportation/CTA-Ridership-Daily-Boarding-Totals/6iiy-9s97/about_data"
)
#> ID: 6iiy-9s97
#> Name: CTA - Ridership - Daily Boarding Totals
#> Attribution: Chicago Transit Authority
#> Owner: CTA
#> Provenance: official
#> Description: This dataset shows systemwide boardings for both bus and rail
#> services provided by CTA, dating back to 2001. Daytypes are as follows: W =
#> Weekday, A = Saturday, U = Sunday/Holiday. See attached readme file for
#> information on how these numbers are calculated.
#> Created: 2011-08-12 15:40:31
#> Data last updated: 2025-06-30 18:44:33
#> Metadata last Updated: 2025-06-30 18:44:32
#> Domain Category: Transportation
#> Domain Tags: cta, public transit, and ridership
#> Domain fields:
#> • Data Owner: Chicago Transit Authority
#> Columns:
#> # A tibble: 5 × 4
#>   column_name    column_label   column_datatype column_description
#>   <chr>          <chr>          <chr>           <chr>             
#> 1 service_date   service_date   calendar_date   ""                
#> 2 day_type       day_type       text            ""                
#> 3 bus            bus            number          ""                
#> 4 rail_boardings rail_boardings number          ""                
#> 5 total_rides    total_rides    number          ""
#> Permalink: https://data.cityofchicago.org/d/6iiy-9s97
#> Link:
#> https://data.cityofchicago.org/Transportation/CTA-Ridership-Daily-Boarding-Totals/6iiy-9s97
#> License: See Terms of Use
```
