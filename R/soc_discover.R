#' Discover datasets and public data assets using the Socrata Discovery API
#'
#' Provides access to the Socrata Discovery API, allowing you to search tens of thousands
#' of government datasets and assets published on the Socrata platform. Governments at
#' all levels publish data on topics including crime, permits, finance, healthcare,
#' research, and performance.
#'
#' @param attribution string; Filter by the attribution or publisher
#' @param categories character vector; Filter by categories.
#' @param domain_category string; Filter by domain category (requires a specified domain).
#' @param domains character vector; Filter to domains.
#' @param ids character vector; Filter by an asset IDs.
#' @param names character vector; Filter by asset names.
#' @param only character vector; Filter to specific asset types. Must be one or more of: `"chart"`, `"dataset"`, `"filter"`, `"link"`, `"map"`, `"measure"`, `"story"`, `"system_dataset"`, `"visualization"`. Default is `"dataset"`.
#' @param provenance string; Filter by provenance: `"official"` or `"community"`.
#' @param query character string; Filter using a a token matching one from an asset's name, description, category, tags, column names, column fieldnames, column descriptions or attribution.
#' @param tags character vector; Filter by tags associated with the assets.
#' @param domain_tags string; Filter by domain tags associated with the assets (requires a specified domain).
#' @param location string; Regional API domain: `"us"` (default) or `"eu"`.
#' @param limit whole number; Maximum number of results (cannot exceed 10,000).
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
#' \donttest{
#' # Search for crime-related datasets in the Public Safety category
#' results <- soc_discover(
#'   query = "crime",
#'   categories = "Public Safety",
#'   only = "dataset"
#' )
#' }
#'
#' @seealso \url{https://dev.socrata.com/docs/other/discovery}
#'
#' @export
soc_discover <- function(
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
) {
  check_string(attribution, allow_null = TRUE)
  check_character(categories, allow_null = TRUE)
  check_string(domain_category, allow_null = TRUE)
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
      ),
      multiple = TRUE
    )
  }
  check_string(provenance, allow_null = TRUE)
  if (!is.null(provenance)) {
    rlang::arg_match(provenance, c("official", "community"))
  }
  check_string(query, allow_null = TRUE)
  check_character(tags, allow_null = TRUE)
  check_character(domain_tags, allow_null = TRUE)
  check_string(location, allow_null = TRUE)
  rlang::arg_match(location, c("us", "eu"))
  check_number_whole(limit)
  if (limit < 1 && limit > 10000) {
    cli::cli_abort("{.arg limit} must be a whole number between 1 and 10,000.")
  }
  if (!is.null(domain_category) || !is.null(domain_tags)) {
    if (is.null(domains) || length(domains) != 1) {
      cli::cli_abort(
        "A single domain must be specified to utilize the {.arg domain_category} and {.arg domain_tags} arguments."
      )
    }
    if (!is.null(categories) || !is.null(tags)) {
      cli::cli_abort(
        "{.arg domain_category} and {.arg domain_tags} must not be specified at the same time as {.arg tags} or {.arg categories}."
      )
    }
  }

  req_url <- paste0("https://api.", location, ".socrata.com/api/catalog/v1")

  req <- httr2::request(req_url) |>
    httr2::req_url_query(
      attribution = attribution,
      provenance = provenance,
      q = query,
      limit = limit
    ) |>
    httr2::req_url_query(
      ids = ids,
      only = only,
      .multi = "comma"
    ) |>
    httr2::req_url_query(
      names = names,
      provenance = provenance,
      q = query,
      .multi = "explode"
    )
  if (!is.null(domain_category) || !is.null(domain_tags)) {
    req <- httr2::req_url_query(
      req,
      search_context = domains,
      categories = domain_category,
      tags = domain_tags,
      .multi = "explode"
    )
  } else {
    req <- req |>
      httr2::req_url_query(
        domains = domains,
        .multi = "comma"
      ) |>
      httr2::req_url_query(
        categories = categories,
        tags = tags,
        .multi = "explode"
      )
  }

  resp <- req |>
    httr2::req_perform()

  results <- resp |>
    list() |>
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
