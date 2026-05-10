# Build a Socrata Query Object

Constructs a structured representation of a Socrata Query Language
(SOQL) query that can be used with Socrata API endpoints. This function
does not execute the query; it creates an object that can be passed to
request functions or printed for inspection.

## Usage

``` r
soc_query(
  select = "*",
  where = NULL,
  group_by = NULL,
  having = NULL,
  order_by = NULL,
  limit = NULL
)
```

## Arguments

- select:

  string; Columns to retrieve.

- where:

  string; Filter conditions.

- group_by:

  string; Fields to group by.

- having:

  string; Conditions to apply to grouped records.

- order_by:

  string; Sort order.

- limit:

  whole number; The maximum number of records to return.

## Value

An object of class `soc_query`, which prints in a readable format and
can be used to build query URLs.

## See also

Use this with a function that executes Socrata requests, e.g.,
`soc_read(url, query = soc_query(...))`

## Examples

``` r
query <- soc_query(
  select = "region, avg(magnitude) as avg_magnitude, count(*) as count",
  group_by = "region",
  having = "count >= 5",
  order_by = "avg_magnitude DESC"
)
print(query)
#> SELECT region, avg(magnitude) as avg_magnitude, count(*) as count
#> GROUP BY region
#> HAVING count >= 5
#> ORDER BY avg_magnitude DESC

if (FALSE) { # interactive() && httr2::is_online()
earthquakes_by_region <- soc_read(
  "https://soda.demo.socrata.com/dataset/USGS-Earthquakes-2012-11-08/3wfw-mdbc/",
  query = query
)
}
```
