#' Read a Socrata Dataset into R
#'
#' Downloads and parses a dataset from a Socrata open data portal URL, returning it as a tibble or `sf` object.
#' Metadata is also returned as attributes on the returned object.
#'
#' @param url string; URL of the Socrata dataset.
#' @param query `soc_query()`; Query parameters specification
#' @param alias string; Use of field alias values. There are three options:
#'
#'  - `"label"`: field alias values are assigned as a label attribute for each field.
#'  - `"replace"`: field alias values replace existing column names.
#'  - `"drop"`: field alias values replace existing column names.
#' @param page_size whole number; Maximum number of rows returned per request.
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
  page_size = 10000
) {
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
  rlang::arg_match(alias, c("label", "replace", "drop"))

  url_base <- httr2::url_modify(
    url,
    username = NULL,
    password = NULL,
    port = NULL,
    path = NULL,
    query = NULL,
    fragment = NULL
  )
  four_by_four <- get_four_by_four(url)

  resps <- iterative_requests(url_base, four_by_four, query, page_size)

  res_list <- parse_data_json(
    json_strs = sapply(resps, httr2::resp_body_string),
    header_col_names = httr2::resp_header(resps[[1]], "X-SODA2-Fields"),
    header_col_types = httr2::resp_header(resps[[1]], "X-SODA2-Types"),
    meta_url = httr2::url_modify(
      url_base,
      path = paste0("api/views/", four_by_four)
    )
  )

  col_types <- httr2::resp_header(resps[[1]], "X-SODA2-Types") |>
    json_header_to_vec()
  for (i in seq_along(res_list)) {
    if (col_types[i] %in% c("url", "location")) {
      res_list[[i]] <- tibble::as_tibble(res_list[[i]])
    } else if (
      col_types[i] %in%
        c("point", "line", "polygon", "multipoint", "multiline", "multipolygon")
    ) {
      res_list[[i]] <- sf::st_sfc(res_list[[i]])
    }

    if (col_types[i] == "location") {
      res_list[[i]]$geometry <- sf::st_sfc(res_list[[i]]$geometry)
    }
  }

  result <- tibble::as_tibble(res_list)
  if (sum(sapply(res_list, \(x) inherits(x, "sfc"))) == 1) {
    result <- sf::st_as_sf(result)
  }

  set_metadata(result, url, alias)
}

json_header_to_vec <- function(json_string) {
  cleaned <- gsub('^\\[|\\]$', '', json_string)
  items <- strsplit(cleaned, '\\s*,\\s*')[[1]]
  gsub('^"|"$', '', items)
}

iterative_requests <- function(url_base, four_by_four, query, page_size) {
  req <- httr2::request(url_base) |>
    httr2::req_template("GET /resource/{four_by_four}.json") |>
    httr2::req_url_query(!!!query)

  nrow_to_get <- min(query$`$limit`, Inf)
  nrow_got <- 0
  nrow_last_req <- min(page_size, nrow_to_get)

  req <- httr2::req_url_query(req, `$limit` = nrow_last_req)

  resps <- httr2::req_perform_iterative(
    req,
    next_req = function(resp, req) {
      nrow_got <<- nrow_got + nrow_last_req
      if (nrow_got >= nrow_to_get) {
        return(NULL)
      } else if (is.finite(nrow_to_get)) {
        httr2::signal_total_pages(ceiling(nrow_to_get / page_size))
      }

      body_string <- httr2::resp_body_string(resp)
      if (gsub("\\s+", "", body_string) %in% c("{}", "[]", "")) {
        return(NULL)
      }

      httr2::req_url_query(
        req,
        `$offset` = nrow_got,
        `$limit` = min(page_size, nrow_to_get - nrow_got)
      )
    },
    max_reqs = Inf
  )

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
