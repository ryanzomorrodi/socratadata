get_four_by_four <- function(url) {
  url_path <- httr2::url_parse(url)$path

  fbf_regex <- "[a-z0-9]{4}-[a-z0-9]{4}"
  regexes <- c(
    v2_api_regex = paste0("^/resource/(", fbf_regex, ")\\.json(?:\\?.*)?$"),
    v3_api_regex = paste0("^/api/v3/views/(", fbf_regex, ")/query\\.json$"),
    permalink_regex = paste0("^/d/(", fbf_regex, ")$"),
    link_regex = paste0("/.*/.*/(", fbf_regex, ")")
  )

  for (regex in regexes) {
    reg <- regmatches(url_path, regexec(regex, url_path))[[1]]
    if (length(reg) > 1) {
      return(reg[2])
    }
  }

  cli::cli_abort("Invalid url.")
}

valid_four_by_four <- function(four_by_four) {
  grepl("^[a-z0-9]{4}-[a-z0-9]{4}$", four_by_four)
}

get_base_url <- function(url) {
  httr2::url_modify(
    url,
    username = NULL,
    password = NULL,
    port = NULL,
    path = NULL,
    query = NULL,
    fragment = NULL
  )
}
