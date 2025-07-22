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
#'   select = "pickup_community_area, count(*) as n",
#'   where = "dropoff_community_area = 31",
#'   group_by = "pickup_community_area",
#'   order_by = "n DESC"
#')
#' print(query)
#'
#' \donttest{
#' trips_to_lws_by_ca <- soc_read(
#'   "https://data.cityofchicago.org/Transportation/Taxi-Trips-2013-2023-/wrvz-psew/about_data",
#'   query = query
#' )
#' }
#'
#' @seealso Use this with a function that executes Socrata requests, e.g., `soc_read(url, query = soc_query(...))`
#'
#' @export
soc_query <- function(
  select = NULL,
  where = NULL,
  group_by = NULL,
  having = NULL,
  order_by = NULL,
  limit = NULL
) {
  check_string(select, allow_null = TRUE)
  check_string(where, allow_null = TRUE)
  check_string(group_by, allow_null = TRUE)
  check_string(having, allow_null = TRUE)
  check_string(order_by, allow_null = TRUE)
  check_number_whole(limit, allow_null = TRUE)

  structure(
    list(
      `$select` = select,
      `$where` = where,
      `$group` = group_by,
      `$having` = having,
      `$order` = order_by,
      `$limit` = limit
    ),
    class = "soc_query"
  )
}

#' @export
print.soc_query <- function(x, ...) {
  query <- vector(mode = "character")
  if (!is.null(x$`$select`)) {
    query <- c(query, paste0("{.strong SELECT} ", x$`$select`))
  }
  if (!is.null(x$`$where`)) {
    query <- c(query, paste0("{.strong WHERE} ", x$`$where`))
  }
  if (!is.null(x$`$group`)) {
    query <- c(query, paste0("{.strong GROUP BY} ", x$`$group`))
  }
  if (!is.null(x$`$having`)) {
    query <- c(query, paste0("{.strong HAVING} ", x$`$having`))
  }
  if (!is.null(x$`$order`)) {
    query <- c(query, paste0("{.strong ORDER BY} ", x$`$order`))
  }
  if (!is.null(x$`$limit`)) {
    query <- c(query, paste0("{.strong LIMIT} ", x$`$limit`))
  }

  for (line in query) {
    cli::cli_text(line)
  }

  invisible(x)
}
