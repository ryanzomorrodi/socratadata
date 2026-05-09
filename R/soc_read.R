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
#' @param api_key_id string; API key ID to authenticate requests. (Can also be stored as `"soc_api_key_id"`
#' environment variable)
#' @param api_key_secret string; API key secret to authenticate requests. (Can also be stored as `"soc_api_key_secret"`
#' environment variable)
#' @param timezone string; Timezone to set floating_timestamps to.
#'
#' @return A tibble with an additional `soc_meta` attribute storing metadata.
#' If the dataset contains a single non-nested geospatial field, it will be returned as an `sf` object.
#'
#' @examplesIf interactive() && httr2::is_online()
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
#'
#' @export
soc_read <- function(
  url,
  query = soc_query(),
  alias = "label",
  page_size = 10000,
  include_synthetic_cols = TRUE,
  api_key_id = NULL,
  api_key_secret = NULL,
  timezone = Sys.timezone()
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
  check_string(timezone)

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
  if (!(timezone %in% OlsonNames())) {
    cli::cli_abort(
      "Timezone must be within {.fn OlsonNames}"
    )
  }

  base_url <- get_base_url(url)
  four_by_four <- get_four_by_four(url)
  meta_url <- httr2::url_modify(
    base_url,
    path = paste0("api/views/", four_by_four)
  )

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
    parse_data_resps(meta_url, timezone) |>
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

set_metdata <- function(result, url, alias) {
  metadata <- soc_metadata_from_url(url)
  attr(result, "soc_meta") <- metadata

  col_alias <- metadata$columns$label
  names(col_alias) <- metadata$columns$name
  if (alias == "replace") {
    sf_column <- attr(result, "sf_column")
    if (!is.null(sf_column)) {
      attr(result, "sf_column") <- col_alias[sf_column]
    }
    new_colnames <- col_alias[colnames(result)]
    colnames(result)[!is.na(new_colnames)] <- new_colnames[!is.na(new_colnames)]
  } else if (alias == "label") {
    for (i in seq_along(result)) {
      attr(result[[i]], "label") <- unname(col_alias[colnames(result)[i]])
    }
  }

  result
}
