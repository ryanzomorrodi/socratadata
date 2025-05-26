#' List Available Datasets on a Socrata Portal
#'
#' Retrieves a catalog of available datasets from a Socrata open data portal.
#'
#' @param url A character string specifying the base URL of the Socrata portal (e.g., `"https://data.cityofchicago.org"`).
#'
#' @return A tibble with one row per dataset and the following columns:
#' \describe{
#'   \item{id}{Dataset identifier (four-by-four ID).}
#'   \item{name}{Title of the dataset.}
#'   \item{categories}{Categories associated with the dataset.}
#'   \item{keywords}{Keywords describing the dataset.}
#'   \item{last_updated}{The date of the last dataset modification.}
#'   \item{landing_page}{The landing page url of the dataset.}
#'   \item{description}{Brief description of the dataset's content.}
#' }
#'
#' @examples
#' \dontrun{
#' catalog <- list_socrata("https://data.cityofchicago.org")
#' head(catalog)
#' }
#'
#' @export
list_socrata <- function(url) {
  list_url <- httr2::url_parse(url) |>
    httr2::url_modify(path = "data.json") |>
    httr2::url_build()

  resp <- httr2::request(list_url) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE)

  result <- tibble::as_tibble(resp$dataset)

  result$id <- result$landingPage |> strsplit("/") |> sapply(\(x) x[length(x)])
  result$issued <- as.Date(result$issued)
  result$modified <- as.Date(result$modified)

  result <- result[c(
    "id",
    "title",
    "theme",
    "keyword",
    "modified",
    "landingPage",
    "description"
  )]
  colnames(result) <- c(
    "id",
    "name",
    "categories",
    "keywords",
    "last_updated",
    "landing_page",
    "description"
  )

  result
}
