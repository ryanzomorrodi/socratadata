#' Discover datasets and public data assets using the Socrata Discovery API
#'
#' Provides access to the Socrata Discovery API, allowing you to search tens of thousands
#' of government datasets and assets published on the Socrata platform. Governments at
#' all levels publish data on topics including crime, permits, finance, healthcare,
#' research, and performance.
#'
#' @param attribution string; Filter by the attribution or publisher
#' @param categories character vector; Filter by categories.
#' @param domains character vector; Filter to domains.
#' @param ids character vector; Filter by specific asset IDs.
#' @param names character vector; Filter by asset names.
#' @param only character vector; Filter to specific asset types. Must be one or more of: `"chart"`, `"dataset"`, `"filter"`, `"link"`, `"map"`, `"measure"`, `"story"`, `"system_dataset"`, `"visualization"`. Default is `"dataset"`.
#' @param provenance character vector; Filter by provenance. Must be one or more of: `"official"` or `"community"`.
#' @param query character string; Filter using a a token matching one from an asset's name, description, category, tags, column names, column fieldnames, column descriptions or attribution.
#' @param tags character vector; Filter by tags associated with the assets.
#' @param location string; Regional API domain: `"us"` (default) or `"eu"`.
#' @param chunk_size whole number; Number of results per request; used for pagination. Default is 10,000.
#'
#' @return A tibble containing metadata for each discovered asset. Columns include:
#' \describe{
#'   \item{id}{Asset identifier (four-by-four ID).}
#'   \item{name}{Asset name.}
#'   \item{attribution}{Attribution or publisher of the asset.}
#'   \item{owner_name}{Display name of the asset owner.}
#'   \item{provenance}{Provenance of asset (official or community).}
#'   \item{description}{Textual description of the asset.}
#'   \item{created}{Date asset was created.}
#'   \item{data_last_updated}{Date asset data was last updated}
#'   \item{metadata_last_updated}{Date asset metadata was last updated}
#'   \item{categories}{Category labels assigned to the asset.}
#'   \item{tags}{Tags associated with the asset.}
#'   \item{domain_category}{Category label assigned by the domain.}
#'   \item{domain_tags}{Tags applied by the domain.}
#'   \item{domain_metadata}{Metadata associated with the asset assigned by the domain.}
#'   \item{column_names}{Names of asset columns.}
#'   \item{column_labels}{Labels of asset columns.}
#'   \item{column_datatypes}{Datatypes of asset columns.}
#'   \item{column_descriptions}{Description of asset columns.}
#'   \item{permalink}{Permanent URL where the asset can be accessed.}
#'   \item{link}{Direct asset link.}
#'   \item{license}{License associated with the asset.}
#' }
#'
#' @examples
#' \dontrun{
#' # Search for crime-related datasets in the Public Safety category
#' results <- soc_discover(
#'   query = "crime",
#'   categories = c("Public Safety"),
#'   only = "dataset"
#' )
#' }
#'
#' @seealso \url{https://dev.socrata.com/docs/discovery/}
#'
#' @export
soc_discover <- function(
  attribution = NULL,
  categories = NULL,
  domains = NULL,
  ids = NULL,
  names = NULL,
  only = "dataset",
  provenance = NULL,
  query = NULL,
  tags = NULL,
  location = "us",
  chunk_size = 10000
) {
  check_string(attribution, allow_null = TRUE)
  check_character(categories, allow_null = TRUE)
  check_character(domains, allow_null = TRUE)
  if (!is.null(domains)) {
    domains <- gsub("^https?://", "", domains)
    domains <- gsub("^www\\.", "", domains)
  }
  check_character(ids, allow_null = TRUE)
  check_character(names, allow_null = TRUE)
  check_character(only, allow_null = TRUE)
  if (!is.null(only)) {
    rlang::arg_match(
      only,
      c(
        "chart",
        "dataset",
        "filter",
        "link",
        "map",
        "measure",
        "story",
        "system_dataset",
        "visualization"
      )
    )
  }
  check_character(provenance, allow_null = TRUE)
  if (!is.null(provenance)) {
    rlang::arg_match(provenance, c("official", "community"))
  }
  check_string(query, allow_null = TRUE)
  check_character(tags, allow_null = TRUE)
  check_string(location, allow_null = TRUE)
  rlang::arg_match(location, c("us", "eu"))

  req_url <- paste0("https://api.", location, ".socrata.com/api/catalog/v1")

  # do one request to figure out the number of results
  initial_resp <- httr2::request(req_url) |>
    httr2::req_url_query(
      attribution = attribution,
      categories = categories,
      domains = domains,
      ids = ids,
      names = names,
      only = only,
      provenance = provenance,
      q = query,
      tags = tags,
      limit = 1,
      .multi = "comma"
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  n_results <- initial_resp$resultSetSize
  n_iterations <- ceiling(n_results / chunk_size)

  req <- httr2::request(req_url) |>
    httr2::req_url_query(
      attribution = attribution,
      categories = categories,
      domains = domains,
      ids = ids,
      names = names,
      only = only,
      provenance = provenance,
      q = query,
      tags = tags,
      limit = chunk_size,
      .multi = "comma"
    )
  reqs <- lapply(
    seq_len(n_iterations),
    function(i) {
      httr2::req_url_query(req, offset = chunk_size * (i - 1))
    }
  )

  results <- reqs |>
    httr2::req_perform_sequential() |>
    httr2::resps_successes() |>
    httr2::resps_data(
      \(resp) httr2::resp_body_json(resp, simplifyVector = TRUE)$results
    )

  tibble::tibble(
    id = results$resource$id,
    name = results$resource$name,
    attribution = results$resource$attribution,
    owner_name = results$owner$display_name,
    provenance = results$resource$provenance,
    description = results$resource$description,
    created = as.POSIXct(results$resource$createdAt, tz = "UTC"),
    data_last_updated = as.POSIXct(
      results$resource$data_updated_at,
      tz = "UTC"
    ),
    metadata_last_updated = as.POSIXct(
      results$resource$metadata_updated_at,
      tz = "UTC"
    ),
    categories = results$classification$categories,
    tags = results$classification$tags,
    domain_category = results$classification$domain_category,
    domain_tags = results$classification$domain_tags,
    domain_metadata = results$classification$domain_metadata,
    column_names = results$resource$columns_name,
    column_labels = results$resource$columns_field_name,
    column_datatypes = results$resource$columns_datatype,
    column_descriptions = results$resource$columns_description,
    permalink = results$permalink,
    link = results$link,
    license = results$metadata$license
  )
}
