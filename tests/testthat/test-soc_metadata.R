test_that("soc_metadata", {
  # fmt: skip
  dataset <- tibble::tribble(
        ~ domain, ~ name, ~ logo, ~ tags, ~ email,
        "data.seattle.gov", "City of Seattle", NA_character_, "seattle, open data, washington, open government", "open-data@seattle.gov",
        "data.sfgov.org", "City of San Francisco", NA_character_, "san francisco, california, open data", "open-data@sfgov.org"
      )
  attr(dataset, "id") <- "2646-ez2p"
  attr(dataset, "name") <- "Datasites for APIs.JSON"
  attr(dataset, "created") <- as.POSIXct("2015-01-03 00:13:48", tz = "UTC")
  attr(dataset, "data_last_updated") <- as.POSIXct(
    "2015-01-03 00:56:25",
    tz = "UTC"
  )
  attr(dataset, "metadata_last_updated") <- as.POSIXct(
    "2015-01-03 00:56:27",
    tz = "UTC"
  )
  attr(dataset, "description") <- character()
  attr(dataset$domain, "label") <- "Domain"
  attr(dataset$name, "label") <- "Name"
  attr(dataset$logo, "label") <- "Logo"
  attr(dataset$tags, "label") <- "Tags"
  attr(dataset$email, "label") <- "Email"
  attr(dataset$domain, "description") <- NA_character_
  attr(dataset$name, "description") <- NA_character_
  attr(dataset$logo, "description") <- NA_character_
  attr(dataset$tags, "description") <- NA_character_
  attr(dataset$email, "description") <- NA_character_
  class(dataset) <- c("soc_tbl", "tbl_df", "tbl", "data.frame")

  expected <- structure(
    list(
      id = "2646-ez2p",
      name = "Datasites for APIs.JSON",
      attribution = NULL,
      category = NULL,
      created = as.POSIXct("2015-01-03 00:13:48", tz = "UTC"),
      data_last_updated = as.POSIXct("2015-01-03 00:56:25", tz = "UTC"),
      metadata_last_updated = as.POSIXct("2015-01-03 00:56:27", tz = "UTC"),
      description = character(),
      custom_fields = NULL,
      columns = tibble::tibble(
        name = c("domain", "name", "logo", "tags", "email"),
        label = c("Domain", "Name", "Logo", "Tags", "Email"),
        description = rep(NA_character_, 5)
      )
    ),
    class = "soc_meta"
  )

  expect_equal(soc_metadata(dataset), expected)
  expect_snapshot(print(soc_metadata(dataset)))
})
