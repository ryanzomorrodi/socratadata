create_v2_request <- function(base_url, four_by_four) {
  httr2::request(base_url) |>
    httr2::req_template("GET /resource/{four_by_four}.json") |>
    httr2::req_throttle(capacity = 10000, fill_time_s = 3600) |>
    httr2::req_user_agent(
      "socratadata (https://ryanzomorrodi.github.io/socratadata/)"
    )
}

set_v2_options <- function(req, query, page_size) {
  limit <- query$limit
  names(query) <- paste0("$", names(query))
  names(query) <- gsub("_.*", "", names(query))

  req |>
    httr2::req_url_query(!!!query) |>
    httr2::req_url_query(`$limit` = min(page_size, limit))
}

perform_v2_iteration <- function(req, page_size, limit) {
  httr2::req_perform_iterative(
    req,
    iterate_with_offset_and_limit(
      "$offset",
      "$limit",
      offset = page_size,
      total_limit = min(limit, Inf),
      resp_complete = is_empty_resp
    ),
    max_reqs = Inf
  )
}

# modified from https://github.com/r-lib/httr2/blob/924415c34d21e949bcff7334fb13b343963ec5b0/R/iterate-helpers.R#L58-L89
iterate_with_offset_and_limit <- function(
  offset_param_name,
  limit_param_name,
  offset,
  total_limit,
  resp_complete = NULL
) {
  current_offset <- 0
  current_limit <- min(offset, total_limit)

  function(resp, req) {
    if (
      !isTRUE(resp_complete(resp)) &&
        current_offset + current_limit < total_limit
    ) {
      current_offset <<- current_offset + offset
      current_limit <<- min(offset, total_limit - current_offset)

      url_query_args <- list(current_offset, current_limit)
      names(url_query_args) <- c(offset_param_name, limit_param_name)
      url_query_args$.req <- req
      do.call(httr2::req_url_query, url_query_args)
    }
  }
}
