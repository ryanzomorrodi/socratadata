# Read a Socrata Dataset into R

Downloads and parses a dataset from a Socrata open data portal URL,
returning it as a tibble or `sf` object. Metadata is also returned as
attributes on the returned object.

## Usage

``` r
soc_read(
  url,
  query = soc_query(),
  alias = "label",
  page_size = 10000,
  include_synthetic_cols = TRUE,
  api_key_id = NULL,
  api_key_secret = NULL,
  timezone = Sys.timezone()
)
```

## Arguments

- url:

  string; URL of the Socrata dataset.

- query:

  string or
  [`soc_query()`](https://ryanzomorrodi.github.io/socratadata/reference/soc_query.md);
  Query parameters specification

- alias:

  string; Use of field alias values. There are three options:

  - `"label"`: field alias values are assigned as a label attribute for
    each field.

  - `"replace"`: field alias values replace existing column names.

  - `"drop"`: field alias values replace existing column names.

- page_size:

  whole number; Maximum number of rows returned per request.

- include_synthetic_cols:

  logical; Should synthetic columns be included?

- api_key_id:

  string; API key ID to authenticate requests. (Can also be stored as
  `"soc_api_key_id"` environment variable)

- api_key_secret:

  string; API key secret to authenticate requests. (Can also be stored
  as `"soc_api_key_secret"` environment variable)

- timezone:

  string; Timezone to set floating_timestamps to.

## Value

A tibble with an additional `soc_meta` attribute storing metadata. If
the dataset contains a single non-nested geospatial field, it will be
returned as an `sf` object.

## Examples

``` r
if (FALSE) { # interactive() && httr2::is_online()
soc_read(
  "https://soda.demo.socrata.com/dataset/USGS-Earthquakes-2012-11-08/3wfw-mdbc/"
)

soc_read(
  "https://soda.demo.socrata.com/dataset/USGS-Earthquakes-2012-11-08/3wfw-mdbc/",
  soc_query(
    select = "region, avg(magnitude) as avg_magnitude, count(*) as count",
    group_by = "region",
    having = "count >= 5",
    order_by = "avg_magnitude DESC"
  )
)
}
```
