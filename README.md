
<!-- README.md is generated from README.Rmd. Please edit that file -->

# socratadata

<!-- badges: start -->
<!-- badges: end -->

Explore Socrata data with ease.

`socratadata` provides a modern interface for downloading data from
[Socrata](https://socrata.com) open data portals powered by Rust.
`socratadata` improves upon the existing
[`RSocrata`](https://dev.socrata.com/connectors/rsocrata) package by
introducing support for all [Socrata
datatypes](https://dev.socrata.com/docs/datatypes/), as such
`socratadata` natively supports datasets with geospatial fields by
returning them as `sf` objects when applicable.

## Installation

You can install the development version of socratadata from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("ryanzomorrodi/socratadata")
```

## Example

Use `list_socrata()` to explore the datasets available on any socrata
data portal.

``` r
library(socratadata)

catalog <- list_socrata("https://data.cityofchicago.org")
print(catalog)
#> # A tibble: 1,045 × 7
#>    id        name      categories keywords last_updated landing_page description
#>    <chr>     <chr>     <list>     <list>   <date>       <chr>        <chr>      
#>  1 22bv-uv6r Open Spa… <chr [1]>  <chr>    2012-09-07   https://dat… "To view o…
#>  2 22u3-xenr Building… <chr [1]>  <chr>    2025-05-25   https://dat… "Violation…
#>  3 24zt-jpfn PoliceDi… <chr [1]>  <chr>    2024-12-02   https://dat… "Current p…
#>  4 26kv-zc52 Librarie… <chr [1]>  <chr>    2023-01-23   https://dat… "The Chica…
#>  5 28km-gtjn Fire Sta… <chr [1]>  <chr>    2019-04-18   https://dat… "Fire stat…
#>  6 28me-84fj Police S… <chr [1]>  <chr>    2025-02-05   https://dat… "This data…
#>  7 28nh-39r3 Christma… <chr [1]>  <chr>    2018-07-11   https://dat… "Locations…
#>  8 2a55-dhk8 Urban Fa… <chr [1]>  <chr>    2018-07-11   https://dat… "The locat…
#>  9 2ani-ic5x COVID-19… <chr [1]>  <chr>    2025-05-21   https://dat… "NOTE: Thi…
#> 10 2b3m-wnm2 7th Ward… <chr [1]>  <chr>    2018-07-11   https://dat… "Applicant…
#> # ℹ 1,035 more rows
```

Use `read_socrata()` to read a socrata dataset into R.

``` r
cta_ridership <- read_socrata(
  "https://data.cityofchicago.org/Transportation/CTA-Ridership-Daily-Boarding-Totals/6iiy-9s97/about_data"
)
print(cta_ridership)
#> ID: 6iiy-9s97
#> Name: CTA - Ridership - Daily Boarding Totals
#> Attribution: Chicago Transit Authority
#> Category: Transportation
#> Created: 2011-08-12 15:40:31
#> Data last Updated: 2025-04-29 16:34:39
#> Metadata last Updated: 2025-04-29 16:35:04
#> Description: This dataset shows systemwide boardings for both bus and rail
#> services provided by CTA, dating back to 2001. Daytypes are as follows: W =
#> Weekday, A = Saturday, U = Sunday/Holiday. See attached readme file for
#> information on how these numbers are calculated.
#> # A tibble: 8,766 × 5
#>    service_date        day_type    bus rail_boardings total_rides
#>    <dttm>              <chr>     <dbl>          <dbl>       <dbl>
#>  1 2001-01-01 00:00:00 U        297192         126455      423647
#>  2 2001-01-02 00:00:00 W        780827         501952     1282779
#>  3 2001-01-03 00:00:00 W        824923         536432     1361355
#>  4 2001-01-04 00:00:00 W        870021         550011     1420032
#>  5 2001-01-05 00:00:00 W        890426         557917     1448343
#>  6 2001-01-06 00:00:00 A        577401         255356      832757
#>  7 2001-01-07 00:00:00 U        375831         169825      545656
#>  8 2001-01-08 00:00:00 W        985221         590706     1575927
#>  9 2001-01-09 00:00:00 W        978377         599905     1578282
#> 10 2001-01-10 00:00:00 W        984884         602052     1586936
#> # ℹ 8,756 more rows
```

Spatial data will be read as an `sf` object.

``` r
chi_community_areas <- read_socrata(
  "https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas/igwz-8jzy/about_data"
)
print(chi_community_areas)
#> ID: igwz-8jzy
#> Name: Boundaries - Community Areas
#> Attribution: City of Chicago
#> Category: Facilities & Geographic Boundaries
#> Created: 2013-01-07 02:02:50
#> Data last Updated: 2025-04-22 23:06:37
#> Metadata last Updated: 2025-04-22 23:06:35
#> Description: Community area boundaries in Chicago.  This dataset is in a format
#> for spatial datasets that is inherently tabular but allows for a map as a
#> derived view. Please click the indicated link below for such a map.  To export
#> the data in either tabular or geographic format, please use the Export button
#> on this dataset.
#> Simple feature collection with 77 features and 5 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -87.94011 ymin: 41.64454 xmax: -87.52414 ymax: 42.02304
#> Geodetic CRS:  WGS 84
#> # A tibble: 77 × 6
#>                              the_geom area_numbe community area_num_1 shape_area
#>                    <MULTIPOLYGON [°]>      <dbl> <chr>     <chr>           <dbl>
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
#> # ℹ 1 more variable: shape_len <dbl>
```
