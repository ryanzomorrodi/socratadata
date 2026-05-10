skip_if_no_api_key <- function() {
  skip_if(
    is.na(Sys.getenv("soc_api_key_id", NA)) ||
      is.na(Sys.getenv("soc_api_key_secret", NA)),
    message = "No api key or secret"
  )
}

append_api_keys <- function(args) {
  c(
    args,
    api_key_id = Sys.getenv("api_key_id"),
    api_key_secret = Sys.getenv("api_key_secret")
  )
}

limit_attr_to_expected <- function(object, expected) {
  attributes(object) <- attributes(object)[
    names(attributes(object)) %in% names(attributes(expected))
  ]

  object
}
