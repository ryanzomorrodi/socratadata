#' Build a Socrata Query Object
#'
#' Constructs a structured representation of a Socrata Query Language (SOQL) query that can be used with Socrata API endpoints.
#' This function does not execute the query; it creates an object that can be passed to request functions or printed for inspection.
#'
#' @param select string; Columns to retrieve.
#' @param where string; Filter conditions.
#' @param group_by string; Fields to group by.
#' @param having string; Conditions to apply to grouped records.
#' @param order_by string; Sort order.
#' @param limit whole number; The maximum number of records to return.
#'
#' @return An object of class `soc_query`, which prints in a readable format and can be used to build query URLs.
#'
#' @examples
#' query <- soc_query(
#'   select = "region, avg(magnitude) as avg_magnitude, count(*) as count",
#'   group_by = "region",
#'   having = "count >= 5",
#'   order_by = "avg_magnitude DESC"
#' )
#' print(query)
#'
#' @examplesIf interactive() && httr2::is_online()
#' earthquakes_by_region <- soc_read(
#'   "https://soda.demo.socrata.com/dataset/USGS-Earthquakes-2012-11-08/3wfw-mdbc/",
#'   query = query
#' )
#'
#' @seealso Use this with a function that executes Socrata requests, e.g., `soc_read(url, query = soc_query(...))`
#'
#' @export
soc_query <- function(
  select = "*",
  where = NULL,
  group_by = NULL,
  having = NULL,
  order_by = NULL,
  limit = NULL
) {
  check_string(select)
  check_string(where, allow_null = TRUE)
  check_string(group_by, allow_null = TRUE)
  check_string(having, allow_null = TRUE)
  check_string(order_by, allow_null = TRUE)
  check_number_whole(limit, allow_null = TRUE)

  query <- as.list(environment())
  class(query) <- "soc_query"

  query
}

#' @export
print.soc_query <- function(x, ...) {
  query_parts <- get_query_parts(x)

  lines <- paste(
    paste0("{.strong ", query_parts$clauses, "}"),
    query_parts$params
  )

  for (line in lines) {
    cli::cli_text(line)
  }

  invisible(x)
}

stringify_query <- function(query) {
  if (is.character(query)) {
    return(query)
  }
  if (is.null(query$select)) {
    query$select <- "*"
  }

  query_parts <- get_query_parts(query)
  paste(query_parts$clauses, query_parts$params, collapse = " ")
}

get_query_parts <- function(query) {
  action_is_not_null <- !vapply(query, is.null, logical(1))

  list(
    clauses = names(query)[action_is_not_null] |>
      gsub(pattern = "_", replacement = " ") |>
      toupper(),
    params = query[action_is_not_null]
  )
}
