create_v3_request <- function(base_url, four_by_four) {
  httr2::request(base_url) |>
    httr2::req_template("POST /api/v3/views/{four_by_four}/query.json") |>
    httr2::req_throttle(capacity = 10000, fill_time_s = 3600) |>
    httr2::req_user_agent(
      "socratadata (https://ryanzomorrodi.github.io/socratadata/)"
    )
}

set_basic_auth <- function(req, api_key_id, api_key_secret) {
  httr2::req_auth_basic(
    req,
    username = api_key_id,
    password = api_key_secret
  )
}

set_v3_options <- function(req, query, include_synthetic_cols, page_size) {
  httr2::req_body_json(
    req,
    data = list(
      query = stringify_query(query),
      page = list(pageNumber = 1L, pageSize = page_size),
      includeSynthetic = include_synthetic_cols
    )
  )
}

perform_v3_iteration <- function(req) {
  httr2::req_perform_iterative(
    req,
    iterate_with_json_body_offset,
    max_reqs = Inf
  )
}

iterate_with_json_body_offset <- function(resp, req) {
  if (is_empty_resp(resp)) {
    return(NULL)
  }

  body_page <- httr2::req_get_body(req)$page
  body_page$pageNumber <- body_page$pageNumber + 1

  httr2::req_body_json_modify(req, page = body_page)
}

is_empty_resp <- function(resp) {
  body_string <- httr2::resp_body_string(resp)
  if (gsub("\\s+", "", body_string) %in% c("{}", "[]", "")) {
    return(TRUE)
  }
  FALSE
}
