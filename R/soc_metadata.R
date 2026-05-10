#' Extract Socrata Dataset Metadata
#'
#' Retrieves metadata attributes from a tibble returned by `soc_read()` or using the dataset url, including
#' dataset-level information and column-level descriptions.
#'
#' This function pulls out descriptive metadata such as the dataset's ID, title, attribution, category,
#' creation and update timestamps, description, any domain-specific fields, and field descriptions defined by the
#' data provider.
#'
#' @param dataset A tibble returned by `soc_read()` or a url.
#'
#' @return An object of class `soc_meta`, which includes:
#' \describe{
#'   \item{id}{Asset identifier (four-by-four ID).}
#'   \item{name}{Asset name.}
#'   \item{attribution}{Attribution or publisher of the asset.}
#'   \item{attribution_link}{Link to attribution.}
#'   \item{resource_type}{Type of resource: api, calendar, chart, dataset, federated_href, file, filter, form, href, link, map, measure, story, visualization.}
#'   \item{owner}{Owner:
#'     \describe{
#'       \item{id}{Owner ID.}
#'       \item{display_name}{Display name of owner.}
#'     }
#'   }
#'   \item{provenance}{Provenance of asset (official or community).}
#'   \item{description}{Textual description of the asset.}
#'   \item{created}{Date asset was created.}
#'   \item{published}{Date asset was published (if published).}
#'   \item{data_last_updated}{Date asset data was last updated}
#'   \item{metadata_last_updated}{Date asset metadata was last updated}
#'   \item{domain_category}{Category label assigned by the domain.}
#'   \item{domain_tags}{Tags applied by the domain.}
#'   \item{domain_metadata}{Metadata associated with the asset assigned by the domain.}
#'   \item{columns}{A dataframe with the following columns:
#'     \describe{
#'       \item{name}{Names of asset columns.}
#'       \item{label}{Labels of asset columns.}
#'       \item{description}{Description of asset columns.}
#'       \item{datatype}{Datatypes of asset columns.}
#'     }
#'   }
#'   \item{permalink}{Permanent URL where the asset can be accessed.}
#'   \item{license}{License associated with the asset.}
#' }
#'
#' @examplesIf interactive() && httr2::is_online()
#' url <- "https://soda.demo.socrata.com/dataset/USGS-Earthquakes-2012-11-08/3wfw-mdbc/"
#' data <- soc_read(url, soc_query(limit = 1000L))
#' metadata <- soc_metadata(data)
#' print(metadata)
#'
#' metadata <- soc_metadata(url)
#' print(metadata)
#'
#' @export
soc_metadata <- function(dataset) {
  if (is.data.frame(dataset)) {
    soc_metadata_from_tibble(dataset)
  } else if (
    .rlang_check_is_string(
      dataset,
      allow_empty = FALSE,
      allow_na = FALSE,
      allow_null = FALSE
    )
  ) {
    soc_metadata_from_url(dataset)
  } else {
    stop_input_type(
      dataset,
      "a dataframe or url",
      arg = rlang::caller_arg(dataset),
      call = rlang::caller_call(n = 0)
    )
  }
}


soc_metadata_from_tibble <- function(soc_tbl) {
  attr(soc_tbl, "soc_meta")
}

soc_metadata_from_url <- function(url) {
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
  resps <- httr2::request(url_base) |>
    httr2::req_template("GET /api/views/{four_by_four}") |>
    httr2::req_perform()

  result <- parse_metadata_resp(resps)
  result$permalink <- paste0(url_base, "d/", four_by_four)

  result
}

#' @export
print.soc_meta <- function(x, ...) {
  cli::cat_line(cli::style_bold("ID: "), x$id)
  cli::cat_line(cli::style_bold("Attribution: "), x$attribution)
  cli::cat_line(cli::style_bold("Attribution Link: "), x$attribution_link)
  cli::cat_line(cli::style_bold("Resource Type: "), x$resource_type)
  cli::cat_line(cli::style_bold("Owner ID: "), x$owner$id)
  cli::cat_line(cli::style_bold("Owner Display Name: "), x$owner$display_name)
  cli::cat_line(cli::style_bold("Provenance: "), x$provenance)
  cli::cat_line(cli::style_bold("Description: "), x$description)
  cli::cat_line(cli::style_bold("Created: "), x$created)
  cli::cat_line(cli::style_bold("Published: "), x$published)
  cli::cat_line(cli::style_bold("Data Last Updated: "), x$data_last_updated)
  cli::cat_line(
    cli::style_bold("Metadata Last Updated: "),
    x$metadata_last_updated
  )
  cli::cat_line(cli::style_bold("Domain Category: "), x$domain_category)
  cli::cat_line(cli::style_bold("Domain Tags: "))
  if (length(x$domain_tags) != 0) {
    cli::cat_bullet(x$domain_tags)
  }
  cli::cat_line(cli::style_bold("Domain Metadata: "))
  if (!is.null(x$domain_metadata) && length(x$domain_metadata) != 0) {
    domain_meta_bullets <- paste0(
      names(x$domain_metadata),
      ": ",
      unlist(x$domain_metadata)
    )
    cli::cat_bullet(domain_meta_bullets)
  }
  cli::cat_line(cli::style_bold("Columns: "))
  print(x$columns)
  cli::cat_line(cli::style_bold("Permalink: "), x$permalink)
  cli::cat_line(cli::style_bold("License: "), x$license)
}
