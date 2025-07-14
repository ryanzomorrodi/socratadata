test_that("soc_metadata_from_tibble", {
  # fmt: skip
  dataset <- tibble::tribble(
        ~ domain, ~ name, ~ logo, ~ tags, ~ email,
        "data.seattle.gov", "City of Seattle", NA_character_, "seattle, open data, washington, open government", "open-data@seattle.gov",
        "data.sfgov.org", "City of San Francisco", NA_character_, "san francisco, california, open data", "open-data@sfgov.org"
      )
  attr(dataset, "id") <- "2646-ez2p"
  attr(dataset, "name") <- "Datasites for APIs.JSON"
  attr(dataset, "owner_name") <- "Chris Metcalf (Developer Experience)"
  attr(dataset, "provenance") <- "official"
  attr(dataset, "created") <- as.POSIXct("2015-01-03 00:13:48", tz = "UTC")
  attr(dataset, "data_last_updated") <- as.POSIXct(
    "2015-01-03 00:56:25",
    tz = "UTC"
  )
  attr(dataset, "metadata_last_updated") <- as.POSIXct(
    "2015-01-03 00:56:27",
    tz = "UTC"
  )
  attr(dataset, "domain_metadata") <- tibble::tibble(
    key = integer(),
    value = logical()
  )
  attr(dataset, "columns") <- tibble::tibble(
    column_name = c("domain", "name", "logo", "tags", "email"),
    column_label = c("Domain", "Name", "Logo", "Tags", "Email"),
    column_datatype = c("text", "text", "text", "text", "text")
  )
  attr(dataset, "permalink") <- "https://soda.demo.socrata.com/d/2646-ez2p"
  attr(
    dataset,
    "link"
  ) <- "https://soda.demo.socrata.com/dataset/Datasites-for-APIs-JSON/2646-ez2p"
  attr(dataset, "license") <- NULL

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

  expected <- structure(
    list(
      id = "2646-ez2p",
      name = "Datasites for APIs.JSON",
      attribution = NULL,
      owner_name = "Chris Metcalf (Developer Experience)",
      provenance = "official",
      description = NULL,
      created = as.POSIXct("2015-01-03 00:13:48", tz = "UTC"),
      data_last_updated = as.POSIXct("2015-01-03 00:56:25", tz = "UTC"),
      metadata_last_updated = as.POSIXct("2015-01-03 00:56:27", tz = "UTC"),
      domain_category = NULL,
      domain_tags = NULL,
      domain_metadata = tibble::tibble(
        key = integer(),
        value = logical()
      ),
      columns = tibble::tibble(
        column_name = c("domain", "name", "logo", "tags", "email"),
        column_label = c("Domain", "Name", "Logo", "Tags", "Email"),
        column_datatype = c("text", "text", "text", "text", "text")
      ),
      permalink = "https://soda.demo.socrata.com/d/2646-ez2p",
      link = "https://soda.demo.socrata.com/dataset/Datasites-for-APIs-JSON/2646-ez2p",
      license = NULL
    ),
    class = "soc_meta"
  )

  expect_equal(soc_metadata(dataset), expected)
  expect_snapshot(print(soc_metadata(dataset)))
})


with_mock_dir("soc_metadata", {
  test_that("soc_metadata_from_url", {
    url <- "https://soda.demo.socrata.com/dataset/Datasites-for-APIs-JSON/2646-ez2p"
    object <- soc_metadata(url)
    # httptest2 doesn't mock redirects
    object$link <- "https://soda.demo.socrata.com/dataset/Datasites-for-APIs-JSON/2646-ez2p"

    expected <- structure(
      list(
        id = "2646-ez2p",
        name = "Datasites for APIs.JSON",
        attribution = NULL,
        owner_name = "Chris Metcalf (Developer Experience)",
        provenance = "official",
        description = NULL,
        created = as.POSIXct("2015-01-03 00:13:48", tz = "UTC"),
        data_last_updated = as.POSIXct("2015-01-03 00:56:25", tz = "UTC"),
        metadata_last_updated = as.POSIXct("2015-01-03 00:56:27", tz = "UTC"),
        domain_category = NULL,
        domain_tags = NULL,
        domain_metadata = tibble::tibble(
          key = integer(),
          value = logical()
        ),
        columns = tibble::tibble(
          column_name = c("domain", "name", "logo", "tags", "email"),
          column_label = c("Domain", "Name", "Logo", "Tags", "Email"),
          column_datatype = c("text", "text", "text", "text", "text")
        ),
        permalink = "https://soda.demo.socrata.com/d/2646-ez2p",
        link = "https://soda.demo.socrata.com/dataset/Datasites-for-APIs-JSON/2646-ez2p",
        license = NULL
      ),
      class = "soc_meta"
    )

    expect_equal(object, expected = expected)
  })
})
