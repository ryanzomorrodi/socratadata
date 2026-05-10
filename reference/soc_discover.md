# Discover datasets and public data assets using the Socrata Discovery API

Provides access to the Socrata Discovery API, allowing you to search
tens of thousands of government datasets and assets published on the
Socrata platform. Governments at all levels publish data on topics
including crime, permits, finance, healthcare, research, and
performance.

## Usage

``` r
soc_discover(
  attribution = NULL,
  categories = NULL,
  domain_category = NULL,
  domains = NULL,
  ids = NULL,
  names = NULL,
  only = "dataset",
  provenance = NULL,
  query = NULL,
  tags = NULL,
  domain_tags = NULL,
  location = "us",
  limit = 10000
)
```

## Arguments

- attribution:

  string; Filter by the attribution or publisher

- categories:

  character vector; Filter by categories.

- domain_category:

  string; Filter by domain category (requires a specified domain).

- domains:

  character vector; Filter to domains.

- ids:

  character vector; Filter by an asset IDs.

- names:

  character vector; Filter by asset names.

- only:

  character vector; Filter to specific asset types. Must be one or more
  of: `"chart"`, `"dataset"`, `"filter"`, `"link"`, `"map"`,
  `"measure"`, `"story"`, `"system_dataset"`, `"visualization"`. Default
  is `"dataset"`.

- provenance:

  string; Filter by provenance: `"official"` or `"community"`.

- query:

  character string; Filter using a a token matching one from an asset's
  name, description, category, tags, column names, column fieldnames,
  column descriptions or attribution.

- tags:

  character vector; Filter by tags associated with the assets.

- domain_tags:

  string; Filter by domain tags associated with the assets (requires a
  specified domain).

- location:

  string; Regional API domain: `"us"` (default) or `"eu"`.

- limit:

  whole number; Maximum number of results (cannot exceed 10,000).

## Value

A tibble containing metadata for each discovered asset. Columns include:

- id:

  Asset identifier (four-by-four ID).

- parent_ids:

  Asset parent identifiers.

- name:

  Asset name.

- attribution:

  Attribution or publisher of the asset.

- attribution_link:

  Link to attribution.

- contact_email:

  Email to contact asset owner.

- resource_type:

  Type of resource: api, calendar, chart, dataset, federated_href, file,
  filter, form, href, link, map, measure, story, visualization.

- owner:

  Owner:

  id

  :   Owner ID.

  display_name

  :   Display name of owner.

- creator:

  Creator:

  id

  :   Creator ID.

  display_name

  :   Display name of creator.

- provenance:

  Provenance of asset (official or community).

- description:

  Textual description of the asset.

- created:

  Date asset was created.

- updated:

  Date asset was last updated.

- published:

  Date asset was published (if published).

- data_last_updated:

  Date asset data was last updated

- metadata_last_updated:

  Date asset metadata was last updated

- categories:

  Category labels assigned to the asset.

- tags:

  Tags associated with the asset.

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

- link:

  Direct asset link.

- domain:

  Domain of the asset.

- license:

  License associated with the asset.

- page_views_last_week:

  Page views in the last week.

- page_views_last_month:

  Page views in the last month.

- page_views_total:

  Total page views.

- downloads:

  Total number of downloads.

## See also

<https://dev.socrata.com/docs/other/discovery>

## Examples

``` r
if (FALSE) { # interactive() && httr2::is_online()
# Search for crime-related datasets in the Public Safety category
results <- soc_discover(
  query = "crime",
  categories = "Public Safety",
  only = "dataset"
)
}
```
