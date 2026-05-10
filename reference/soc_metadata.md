# Extract Socrata Dataset Metadata

Retrieves metadata attributes from a tibble returned by
[`soc_read()`](https://ryanzomorrodi.github.io/socratadata/reference/soc_read.md)
or using the dataset url, including dataset-level information and
column-level descriptions.

## Usage

``` r
soc_metadata(dataset)
```

## Arguments

- dataset:

  A tibble returned by
  [`soc_read()`](https://ryanzomorrodi.github.io/socratadata/reference/soc_read.md)
  or a url.

## Value

An object of class `soc_meta`, which includes:

- id:

  Asset identifier (four-by-four ID).

- name:

  Asset name.

- attribution:

  Attribution or publisher of the asset.

- attribution_link:

  Link to attribution.

- resource_type:

  Type of resource: api, calendar, chart, dataset, federated_href, file,
  filter, form, href, link, map, measure, story, visualization.

- owner:

  Owner:

  id

  :   Owner ID.

  display_name

  :   Display name of owner.

- provenance:

  Provenance of asset (official or community).

- description:

  Textual description of the asset.

- created:

  Date asset was created.

- published:

  Date asset was published (if published).

- data_last_updated:

  Date asset data was last updated

- metadata_last_updated:

  Date asset metadata was last updated

- domain_category:

  Category label assigned by the domain.

- domain_tags:

  Tags applied by the domain.

- domain_metadata:

  Metadata associated with the asset assigned by the domain.

- columns:

  A dataframe with the following columns:

  name

  :   Names of asset columns.

  label

  :   Labels of asset columns.

  description

  :   Description of asset columns.

  datatype

  :   Datatypes of asset columns.

- permalink:

  Permanent URL where the asset can be accessed.

- license:

  License associated with the asset.

## Details

This function pulls out descriptive metadata such as the dataset's ID,
title, attribution, category, creation and update timestamps,
description, any domain-specific fields, and field descriptions defined
by the data provider.

## Examples

``` r
if (FALSE) { # interactive() && httr2::is_online()
url <- "https://soda.demo.socrata.com/dataset/USGS-Earthquakes-2012-11-08/3wfw-mdbc/"
data <- soc_read(url, soc_query(limit = 1000L))
metadata <- soc_metadata(data)
print(metadata)

metadata <- soc_metadata(url)
print(metadata)
}
```
