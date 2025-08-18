#' Read a Socrata Dataset into R
#'
#' Downloads and parses a dataset from a Socrata open data portal URL, returning it as a tibble or `sf` object.
#' Metadata is also returned as attributes on the returned object.
#'
#' @param url string; URL of the Socrata dataset.
#' @param query string or `soc_query()`; Query parameters specification
#' @param alias string; Use of field alias values. There are three options:
#'
#'  - `"label"`: field alias values are assigned as a label attribute for each field.
#'  - `"replace"`: field alias values replace existing column names.
#'  - `"drop"`: field alias values replace existing column names.
#' @param page_size whole number; Maximum number of rows returned per request.
#' @param include_synthetic_cols logical; Should synthetic columns be included?
#' @param api_key_id string; API key ID to authenticate requests. (Can also be stored as `"soc_api_key_id"``
#' environment variable)
#' @param api_key_secret string; API key secret to authenticate requests. (Can also be stored as `"soc_api_key_secret"``
#' environment variable)
#'
#' @return A tibble with additional attributes containing dataset metadata.
#' If the dataset contains a single non-nested geospatial field, it will be returned as an `sf` object.
#'
#' The returned object has the following attributes:
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
#'   \item{domain_category}{Category label assigned by the domain.}
#'   \item{domain_tags}{Tags applied by the domain.}
#'   \item{domain_metadata}{Metadata associated with the asset assigned by the domain.}
#'   \item{columns}{A dataframe with the following columns:
#'     \describe{
#'       \item{column_name}{Names of asset columns.}
#'       \item{column_label}{Labels of asset columns.}
#'       \item{column_datatype}{Datatypes of asset columns.}
#'       \item{column_description}{Description of asset columns.}
#'     }
#'   }
#'   \item{permalink}{Permanent URL where the asset can be accessed.}
#'   \item{link}{Direct asset link.}
#'   \item{license}{License associated with the asset.}
#' }
#'
#' @examples
#' \donttest{
#' soc_read(
#'   "https://soda.demo.socrata.com/dataset/USGS-Earthquakes-2012-11-08/3wfw-mdbc/"
#' )
#'
#' soc_read(
#'   "https://soda.demo.socrata.com/dataset/USGS-Earthquakes-2012-11-08/3wfw-mdbc/",
#'   soc_query(
#'     select = "region, avg(magnitude) as avg_magnitude, count(*) as count",
#'     group_by = "region",
#'     having = "count >= 5",
#'     order_by = "avg_magnitude DESC"
#'   )
#' )
#' }
#'
#' @export
soc_read <- function(
  url,
  query = soc_query(),
  alias = "label",
  page_size = 10000,
  include_synthetic_cols = TRUE,
  api_key_id = NULL,
  api_key_secret = NULL
) {
  check_string(url)
  if (is.character(query)) {
    check_string(query)
  } else if (!inherits(query, "soc_query")) {
    stop_input_type(
      query,
      "a <soc_query> object",
      arg = rlang::caller_arg(query),
      call = rlang::caller_call(n = 0)
    )
  }
  check_string(alias)
  rlang::arg_match(alias, c("label", "replace", "drop"))
  check_number_whole(page_size, min = 1)
  check_string(api_key_id, allow_null = TRUE)
  check_string(api_key_secret, allow_null = TRUE)

  api_key_id <- api_key_id %||% Sys_get_env("soc_api_key_id")
  api_key_secret <- api_key_secret %||% Sys_get_env("soc_api_key_secret")
  if (is.null(api_key_id) && is.null(api_key_secret)) {
    request_version <- "v2"
    if (!inherits(query, "soc_query")) {
      cli::cli_abort(
        "{.arg soc_query} must be a <soc_query> object to perform a v2.1 request. Provide an {.arg api_key_id} and {.arg api_key_secret} to perform a v3 request."
      )
    }
    cli::cli_alert_info(
      "Utilizing v2.1 API. {.arg include_synthetic_cols} will be ignored. Provide an {.arg api_key_id} and {.arg api_key_secret} to perform a v3 request."
    )
  } else if (is.null(api_key_id) || is.null(api_key_secret)) {
    cli::cli_abort(
      "Both an {.arg api_key_id} and {.arg api_key_secret} must be specified to authenticate a v3 request."
    )
  } else {
    check_string(api_key_id)
    check_string(api_key_secret)
    request_version <- "v3"
  }

  base_url <- get_base_url(url)
  four_by_four <- get_four_by_four(url)

  resps <- switch(
    request_version,
    v2 = {
      create_v2_request(base_url, four_by_four) |>
        set_v2_options(query, page_size) |>
        perform_v2_iteration(page_size, query$limit)
    },
    v3 = {
      create_v3_request(base_url, four_by_four) |>
        set_basic_auth(api_key_id, api_key_secret) |>
        set_v3_options(query, include_synthetic_cols, page_size) |>
        perform_v3_iteration()
    }
  )

  resps |>
    parse_resps() |>
    convert_list_to_df() |>
    set_metdata(url, alias)
}

Sys_get_env <- function(x) {
  envvar <- Sys.getenv(x, NA)
  if (is.na(envvar)) {
    NULL
  } else {
    envvar
  }
}

parse_resps <- function(resps) {
  resp_strings <- lapply(resps, httr2::resp_body_raw)
  header_col_names <- httr2::resp_header(resps[[1]], "X-SODA2-Fields")
  header_col_types <- httr2::resp_header(resps[[1]], "X-SODA2-Types")

  resp_url <- httr2::resp_url(resps[[1]])
  base_url <- get_base_url(resp_url)
  four_by_four <- get_four_by_four(resp_url)
  meta_url <- httr2::url_modify(
    base_url,
    path = paste0("api/views/", four_by_four)
  )

  parse_data_json(resp_strings, header_col_names, header_col_types, meta_url)
}

convert_list_to_df <- function(parsed_list) {
  spatial_cols <- vapply(parsed_list, is_sfc, logical(1))
  list_cols <- vapply(parsed_list, is.list, logical(1)) & !spatial_cols
  location_cols <- vapply(parsed_list, is_location, logical(1))

  parsed_list[spatial_cols] <- lapply(parsed_list[spatial_cols], sf::st_sfc)
  parsed_list[list_cols] <- lapply(parsed_list[list_cols], tibble::as_tibble)
  parsed_list[location_cols] <- lapply(
    parsed_list[location_cols],
    function(col) {
      col$geometry <- sf::st_sfc(col$geometry)
      col
    }
  )

  result <- tibble::as_tibble(parsed_list)
  if (sum(spatial_cols) == 1) {
    result <- sf::st_as_sf(result)
  }

  result
}

is_sfc <- function(x) {
  inherits(x, "sfc")
}

is_location <- function(x) {
  is.list(x) && is_sfc(x$geometry)
}

set_metdata <- function(result, url, alias) {
  metadata <- soc_metadata_from_url(url)
  for (i in seq_along(metadata)) {
    attr(result, names(metadata)[i]) <- metadata[[i]]
  }

  col_alias <- metadata$columns$column_label
  names(col_alias) <- metadata$columns$column_name
  if (alias == "replace") {
    colnames(result) <- col_alias[colnames(result)]
  } else if (alias == "label") {
    for (i in seq_along(result)) {
      attr(result[[i]], "label") <- unname(col_alias[colnames(result)[i]])
    }
  }

  result
}
