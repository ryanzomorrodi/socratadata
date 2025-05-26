url <- "https://data.cityofchicago.org/Transportation/Taxi-Trips-2013-2023-/wrvz-psew/about_data"

#' Extract Socrata Dataset Metadata
#'
#' Retrieves metadata attributes from a `soc_tbl` object returned by `read_socrata()`, including dataset-level
#' information and column-level descriptions.
#'
#' This function pulls out descriptive metadata such as the dataset's ID, title, attribution, category,
#' creation and update timestamps, description, any custom fields, and field descriptions defined by the data provider.
#'
#' @param soc_tbl A `soc_tbl` object, typically returned by `read_socrata()`.
#'
#' @return An object of class `soc_meta`, which includes:
#' \describe{
#'   \item{id}{The dataset's unique Socrata identifier.}
#'   \item{name}{The name/title of the dataset.}
#'   \item{attribution}{The source or publisher of the data.}
#'   \item{category}{The assigned category or topic of the dataset.}
#'   \item{created}{The datetime when the dataset was created.}
#'   \item{data_last_updated}{The last time the data was updated.}
#'   \item{metadata_last_updated}{The last time the metadata was updated.}
#'   \item{description}{A description of the dataset contents.}
#'   \item{custom_fields}{Any additional metadata fields defined by the data publisher.}
#'   \item{columns}{A tibble with metadata for each column, including `name`, `label` (if available), and `description`.}
#' }
#'
#' @examples
#' \dontrun{
#' url <- "https://data.cityofchicago.org/resource/wrvz-psew.json"
#' data <- read_socrata(url)
#' metadata <- soc_metadata(data)
#' print(metadata)
#' }
#'
#' @seealso [read_socrata()]
#'
#' @export
soc_metadata <- function(soc_tbl) {
  columns <- tibble::tibble(
    name = colnames(soc_tbl)
  )
  if (!is.null(attr(soc_tbl[[1]], "label"))) {
    columns$label <- unname(sapply(soc_tbl, \(col) attr(col, "label")))
  }
  columns$description <- unname(sapply(
    soc_tbl,
    \(col) attr(col, "description")
  ))

  structure(
    list(
      id = attr(soc_tbl, "id"),
      name = attr(soc_tbl, "name"),
      attribution = attr(soc_tbl, "attribution"),
      category = attr(soc_tbl, "category"),
      created = attr(soc_tbl, "created"),
      data_last_updated = attr(soc_tbl, "data_last_updated"),
      metadata_last_updated = attr(soc_tbl, "metadata_last_updated"),
      description = attr(soc_tbl, "description"),
      custom_fields = attr(soc_tbl, "custom_fields"),
      columns = columns
    ),
    class = "soc_meta"
  )
}

#' @export
print.soc_meta <- function(x, ...) {
  cli::cli_text("{.strong ID:} {x$id}")
  cli::cli_text("{.strong Name:} {x$name}")
  cli::cli_text("{.strong Attribution:} {x$attribution}")
  cli::cli_text("{.strong Category:} {x$category}")
  cli::cli_text("{.strong Created:} {x$created}")
  cli::cli_text("{.strong Data last Updated:} {x$data_last_updated}")
  cli::cli_text(
    "{.strong Metadata last Updated:} {x$metadata_last_updated}"
  )
  cli::cli_text("{.strong Description:} {x$description}")
  if (!is.null(x$custom_fields)) {
    cli::cli_text("{.strong Custom Fields:}")
    ul <- cli::cli_ul()
    for (i in seq_along(x$custom_fields)) {
      cli::cli_li(
        "{.strong {names(x$custom_fields)[i]}:} {x$custom_fields[[i]]}"
      )
    }
    cli::cli_end(ul)
  }
  cli::cli_text("{.strong Columns:}")
  print(x$columns, n = 20)
}
