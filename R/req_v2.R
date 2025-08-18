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
  resp_pages = NULL,
  resp_complete = NULL
) {
  known_total <- FALSE
  current_offset <- 0
  current_limit <- min(offset, total_limit)

  function(resp, req) {
    if (!is.null(resp_pages) && !known_total) {
      n <- httr2::resp_pages(resp)
      if (!is.null(n)) {
        known_total <- TRUE
        httr2::signal_total_pages(n)
      }
    }

    if (
      !isTRUE(resp_complete(resp)) &&
        current_offset + current_limit < total_limit
    ) {
      current_offset <<- current_offset + offset
      current_limit <<- min(offset, total_limit - current_offset)
      httr2::req_url_query(
        req,
        !!offset_param_name := current_offset,
        !!limit_param_name := current_limit
      )
    }
  }
}
