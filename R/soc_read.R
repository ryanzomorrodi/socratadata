get_four_by_four <- function(url_parsed) {
  url_path_vec <- strsplit(url_parsed$path, "/")[[1]][-1]

  if (url_path_vec[1] == "resource" || url_path_vec[1] == "d") {
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

get_count_url <- function(url_parsed, four_by_four) {
  url_parsed |>
    httr2::url_modify(path = paste0("/api/id/", four_by_four)) |>
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
#' @param url string; the URL of the Socrata dataset (e.g., from `https://data.cityofchicago.org`).
#' @param query `soc_query()`; query parameters specification
#' @param alias string; use of field alias values. There are two options:
#'
#'  - `"label"`: field alias values are assigned as a label attribute for each field.
#'  - `"replace"`: field alias values replace existing column names.
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
#' cta_ridership <- soc_read(
#'   "https://data.cityofchicago.org/Transportation/CTA-Ridership-Daily-Boarding-Totals/6iiy-9s97/about_data"
#' )
#' print(cta_ridership)
#' attr(cta_ridership, "description")
#'
#' trips_to_lws_by_ca <- soc_read(
#'   "https://data.cityofchicago.org/Transportation/Taxi-Trips-2013-2023-/wrvz-psew/about_data",
#'   query = soc_query(
#'     select = "pickup_community_area, count(*) as n",
#'     where = "dropoff_community_area = 31",
#'     group_by = "pickup_community_area",
#'     order_by = "n DESC"
#'   ),
#'   alias = "replace"
#' )
#' }
#'
#' @export
soc_read <- function(url, query = soc_query(), alias = "label") {
  check_string(url)
  if (!inherits(query, "soc_query")) {
    stop_input_type(
      query,
      "a <soc_query> object",
      arg = rlang::caller_arg(query),
      call = rlang::caller_call(n = 0)
    )
  }
  check_string(alias)
  rlang::arg_match(alias, c("label", "replace"))

  url_parsed <- httr2::url_parse(url)
  four_by_four <- get_four_by_four(url_parsed)

  resps <- iterative_requests(url_parsed, four_by_four, query)

  res_list <- parse_data_json(
    json_str = sapply(resps, httr2::resp_body_string),
    header_col_names = httr2::resp_header(resps[[1]], "X-SODA2-Fields"),
    header_col_types = httr2::resp_header(resps[[1]], "X-SODA2-Types")
  )

  tib_cols <- sapply(res_list, \(x) is.list(x) && !inherits(x, "sfc"))
  res_list[tib_cols] <- lapply(res_list[tib_cols], tibble::as_tibble)
  result <- tibble::as_tibble(res_list)
  if (!is.null(query$`$limit`)) {
    result <- head(result, n = query$`$limit`)
  }

  sf_cols <- sapply(res_list, \(x) inherits(x, "sfc"))
  result[sf_cols] <- lapply(result[sf_cols], sf::st_sfc)
  if (sum(sf_cols) == 1) {
    result <- sf::st_as_sf(result)
  }

  class(result) <- c("socrata_tbl", class(result))

  set_metadata(result, url_parsed, four_by_four, alias)
}

iterative_requests <- function(url_parsed, four_by_four, query) {
  chunk_size <- 10000
  data_url <- get_data_url(url_parsed, four_by_four)

  if (all(sapply(query[2:5], is.null))) {
    count_url <- get_count_url(url_parsed, four_by_four)

    row_count <- httr2::request(count_url) |>
      httr2::req_url_query(
        `$query` = "select count(*) as COLUMN_ALIAS_GUARD__count"
      ) |>
      httr2::req_perform() |>
      httr2::resp_body_json() |>
      unlist() |>
      as.numeric()
    if (!is.null(query$`$limit`)) {
      row_count <- min(row_count, query$`$limit`)
    }
    iteration_count <- ceiling(row_count / chunk_size)

    req <- httr2::request(data_url) |>
      httr2::req_url_query(!!!query)
    reqs <- lapply(
      seq_len(iteration_count),
      function(i) {
        offset <- chunk_size * (i - 1)
        limit <- min(chunk_size, row_count - offset)
        httr2::req_url_query(
          req,
          `$offset` = offset,
          `$limit` = limit,
        )
      }
    )
    resps <- httr2::req_perform_sequential(reqs)
  } else {
    if (!is.null(query$`$limit`)) {
      req_count <- local({
        count <- 1L
        function() {
          count <<- count + 1L
          count
        }
      })
      is_complete <- function(resp) {
        identical(httr2::resp_body_raw(resp), as.raw(c(0x5b, 0x5d, 0x0a))) &&
          (req_count() * chunk_size) >= query$`$limit`
      }
    } else {
      is_complete <- function(resp) {
        identical(httr2::resp_body_raw(resp), as.raw(c(0x5b, 0x5d, 0x0a)))
      }
    }

    req <- httr2::request(data_url) |>
      httr2::req_url_query(!!!query) |>
      httr2::req_url_query(`$limit` = chunk_size)

    resps <- httr2::req_perform_iterative(
      req,
      next_req = httr2::iterate_with_offset(
        "$offset",
        start = 0,
        offset = chunk_size,
        resp_complete = is_complete
      ),
      max_reqs = Inf
    )
  }

  resps
}

set_metadata <- function(result, url_parsed, four_by_four, alias) {
  meta_url <- get_meta_url(url_parsed, four_by_four)

  metadata <- httr2::request(meta_url) |>
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
  attr(result, "description") <- gsub("\\r\\n", "\n", metadata$description)

  col_alias <- sapply(metadata$columns, \(col) col$name)
  col_description <- sapply(
    metadata$columns,
    \(col) ifelse(is.null(col$description), NA_character_, col$description)
  )

  if (alias == "replace") {
    colnames(result) <- col_alias
  } else if (alias == "label") {
    for (i in seq_along(result)) {
      attr(result[[i]], "label") <- col_alias[i]
    }
  }
  for (i in seq_along(result)) {
    attr(result[[i]], "description") <- col_description[[i]]
  }

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
