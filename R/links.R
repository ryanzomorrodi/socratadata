get_four_by_four <- function(url) {
  url_path <- httr2::url_parse(url)$path

  url_path_vec <- strsplit(url_path, "/")[[1]][-1]

  if (url_path_vec[1] == "resource" || url_path_vec[1] == "d") {
    four_by_four <- substr(url_path_vec[2], 1, 9)
  } else {
    four_by_four <- url_path_vec[3]
  }

  if (!valid_four_by_four(four_by_four)) {
    cli::cli_abort("Invalid url.")
  }

  four_by_four
}

valid_four_by_four <- function(four_by_four) {
  grepl("^[a-z0-9]{4}-[a-z0-9]{4}$", four_by_four)
}
