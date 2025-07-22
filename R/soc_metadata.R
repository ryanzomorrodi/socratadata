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
#' url <- "https://data.cityofchicago.org/resource/wrvz-psew.json"
#' data <- soc_read(url)
#' metadata <- soc_metadata(data)
#' print(metadata)
#'
#' metadata <- soc_metadata(url)
#' print(metadata)
#' }
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
  meta_fields <- c(
    "id",
    "name",
    "attribution",
    "owner_name",
    "provenance",
    "description",
    "created",
    "data_last_updated",
    "metadata_last_updated",
    "domain_category",
    "domain_tags",
    "domain_metadata",
    "columns",
    "permalink",
    "link",
    "license"
  )
  names(meta_fields) <- meta_fields

  structure(
    lapply(meta_fields, \(field) attr(soc_tbl, field)),
    class = "soc_meta"
  )
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
  results <- httr2::request(url_base) |>
    httr2::req_template("GET /api/views/{four_by_four}") |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE)

  permalink <- paste0(url_base, "d/", four_by_four)
  link <- httr2::request(permalink) |>
    httr2::req_method("HEAD") |>
    httr2::req_perform() |>
    httr2::resp_url()

  structure(
    list(
      id = results$id,
      name = results$name,
      attribution = results$attribution,
      owner_name = results$owner$screenName,
      provenance = results$provenance,
      description = results$description,
      created = as.POSIXct(results$createdAt, tz = "UTC"),
      data_last_updated = as.POSIXct(results$rowsUpdatedAt, tz = "UTC"),
      metadata_last_updated = as.POSIXct(results$viewLastModified, tz = "UTC"),
      domain_category = results$category,
      domain_tags = results$tags,
      domain_metadata = tibble::enframe(
        unlist(results$metadata$custom_fields$Metadata),
        name = "key"
      ),
      columns = tibble::tibble(
        column_name = results$columns$fieldName,
        column_label = results$columns$name,
        column_datatype = results$columns$dataTypeName,
        column_description = results$columns$description
      ),
      permalink = permalink,
      link = link,
      license = results$license$name
    ),
    class = "soc_meta"
  )
}

#' @export
print.soc_meta <- function(x, ...) {
  cli::cli_text("{.strong ID:} {x$id}")
  cli::cli_text("{.strong Name:} {x$name}")
  cli::cli_text("{.strong Attribution:} {x$attribution}")
  cli::cli_text("{.strong Owner:} {x$owner_name}")
  cli::cli_text("{.strong Provenance:} {x$provenance}")
  cli::cli_text("{.strong Description:} {x$description}")
  cli::cli_text("{.strong Created:} {x$created}")
  cli::cli_text("{.strong Data last updated:} {x$data_last_updated}")
  cli::cli_text(
    "{.strong Metadata last Updated:} {x$metadata_last_updated}"
  )
  cli::cli_text(
    "{.strong Domain Category:} {x$domain_category}"
  )
  cli::cli_text(
    "{.strong Domain Tags:} {x$domain_tags}"
  )
  if (!is.null(x$domain_metadata)) {
    cli::cli_text("{.strong Domain fields:}")
    ul <- cli::cli_ul()
    for (i in seq_len(nrow(x$domain_metadata))) {
      cli::cli_li(
        "{.strong {x$domain_metadata$key[i]}:} {x$domain_metadata$value[i]}"
      )
    }
    cli::cli_end(ul)
  }
  cli::cli_text("{.strong Columns:}")
  print(x$columns, n = 20)
  cli::cli_text("{.strong Permalink:} {x$permalink}")
  cli::cli_text("{.strong Link:} {x$link}")
  cli::cli_text("{.strong License:} {x$license}")
}
