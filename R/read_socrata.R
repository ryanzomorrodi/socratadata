get_four_by_four <- function(url_parsed) {
  url_path_vec <- strsplit(url_parsed$path, "/")[[1]][-1]

  if (url_path_vec[1] == "resource") {
    four_by_four <- substr(url_path_vec[2], 1, 9)
  } else {
    four_by_four <- url_path_vec[3]
  }

  if (!valid_four_by_four(four_by_four)) {
    cli::cli_abort("Invalid url.")
  }

  four_by_four
}

valid_four_by_four <- function(four_by_four) {
  grepl("^[a-z0-9]{4}-[a-z0-9]{4}$", four_by_four)
}

get_data_url <- function(url_parsed, four_by_four) {
  url_parsed |>
    httr2::url_modify(path = paste0("/resource/", four_by_four, ".json")) |>
    httr2::url_build()
}

get_meta_url <- function(url_parsed, four_by_four) {
  url_parsed |>
    httr2::url_modify(path = paste0("/api/views/", four_by_four)) |>
    httr2::url_build()
}

#' Read a Socrata Dataset into R
#'
#' Downloads and parses a dataset from a Socrata open data portal URL, returning it as a tibble or `sf` object.
#' Metadata is also returned as attributes on the returned object.
#'
#' @param url A character string specifying the URL of the Socrata dataset (e.g., from `https://data.cityofchicago.org`).
#'
#' @return A `socrata_tbl`, which is a tibble with additional class and attributes containing dataset metadata.
#' If the dataset contains a single non-nested geospatial field, it will be returned as an `sf` object.
#'
#' The returned object has the following attributes:
#' \describe{
#'   \item{id}{Dataset identifier (four-by-four ID).}
#'   \item{name}{Dataset name.}
#'   \item{attribution}{Attribution or publisher of the dataset.}
#'   \item{category}{Category label assigned on the portal.}
#'   \item{created}{POSIXct timestamp when the dataset was created.}
#'   \item{data_last_updated}{POSIXct timestamp of the last data update.}
#'   \item{metadata_last_updated}{POSIXct timestamp of the last metadata update.}
#'   \item{description}{Textual description of the dataset.}
#' }
#'
#' @examples
#' \dontrun{
#'   url <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json"
#'   data <- read_socrata(url)
#'   print(data)
#'   attr(data, "description")
#' }
#'
#' @export
read_socrata <- function(url) {
  url_parsed <- httr2::url_parse(url)
  four_by_four <- get_four_by_four(url_parsed)

  url_json <- get_data_url(url_parsed, four_by_four)

  req <- httr2::request(url_json) |>
    httr2::req_url_query(`$limit` = 50000)

  is_complete <- function(resp) {
    httr2::resp_body_raw(resp) |>
      identical(as.raw(c(0x5b, 0x5d, 0x0a)))
  }
  resps <- httr2::req_perform_iterative(
    req,
    next_req = httr2::iterate_with_offset(
      "$offset",
      start = 0,
      offset = 50000,
      resp_complete = is_complete
    ),
    max_reqs = Inf
  )

  res_list <- parse_data_json(
    json_str = sapply(resps[-length(resps)], httr2::resp_body_string),
    header_col_names = httr2::resp_header(resps[[1]], "X-SODA2-Fields"),
    header_col_types = httr2::resp_header(resps[[1]], "X-SODA2-Types")
  )

  tib_cols <- sapply(res_list, \(x) is.list(x) && !inherits(x, "sfc"))
  res_list[tib_cols] <- lapply(res_list[tib_cols], tibble::as_tibble)
  result <- tibble::as_tibble(res_list)

  sf_cols <- sapply(res_list, \(x) inherits(x, "sfc"))
  result[sf_cols] <- lapply(result[sf_cols], sf::st_sfc)
  if (sum(sf_cols) == 1) {
    result <- sf::st_as_sf(result)
  }

  meta_json <- get_meta_url(url_parsed, four_by_four)

  metadata <- httr2::request(meta_json) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  attr(result, "id") <- metadata$id
  attr(result, "name") <- metadata$name
  attr(result, "attribution") <- metadata$attribution
  attr(result, "category") <- metadata$category
  attr(result, "created") <- as.POSIXct(metadata$createdAt, tz = "UTC")
  attr(result, "data_last_updated") <- as.POSIXct(
    metadata$rowsUpdatedAt,
    tz = "UTC"
  )
  attr(result, "metadata_last_updated") <- as.POSIXct(
    metadata$viewLastModified,
    tz = "UTC"
  )
  attr(result, "description") <- metadata$description

  class(result) <- c("socrata_tbl", class(result))

  result
}

#' @export
print.socrata_tbl <- function(x, ...) {
  cli::cli_text("{.strong ID:} {attr(x, 'id')}")
  cli::cli_text("{.strong Name:} {attr(x, 'name')}")
  cli::cli_text("{.strong Attribution:} {attr(x, 'attribution')}")
  cli::cli_text("{.strong Category:} {attr(x, 'category')}")
  cli::cli_text("{.strong Created:} {attr(x, 'created')}")
  cli::cli_text("{.strong Data last Updated:} {attr(x, 'data_last_updated')}")
  cli::cli_text(
    "{.strong Metadata last Updated:} {attr(x, 'metadata_last_updated')}"
  )
  cli::cli_text("{.strong Description:} {attr(x, 'description')}")

  NextMethod("print")
}
