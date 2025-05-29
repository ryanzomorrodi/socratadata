#' Read a Socrata Dataset into R
#'
#' Downloads and parses a dataset from a Socrata open data portal URL, returning it as a tibble or `sf` object.
#' Metadata is also returned as attributes on the returned object.
#'
#' @param url string; URL of the Socrata dataset (e.g., from `https://data.cityofchicago.org`).
#' @param query `soc_query()`; Query parameters specification
#' @param alias string; Use of field alias values. There are two options:
#'
#'  - `"label"`: field alias values are assigned as a label attribute for each field.
#'  - `"replace"`: field alias values replace existing column names.
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

  set_metadata(result, url, alias)
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
        identical(httr2::resp_body_raw(resp), as.raw(c(0x5b, 0x5d, 0x0a))) ||
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


set_metadata <- function(result, url, alias) {
  metadata <- soc_metadata_from_url(url)
  for (i in seq_along(metadata)) {
    attr(result, names(metadata)[i]) <- metadata[[i]]
  }

  col_alias <- tibble::deframe(metadata$columns[c(
    "column_name",
    "column_label"
  )])
  if (alias == "replace") {
    colnames(result) <- col_alias[colnames(result)]
  } else if (alias == "label") {
    for (i in seq_along(result)) {
      attr(result[[i]], "label") <- unname(col_alias[colnames(result)[i]])
    }
  }

  result
}
