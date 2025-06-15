with_mock_dir(
  "soc_read",
  {
    test_that("soc_read returns tibble when no spatial cols", {
      url <- "https://soda.demo.socrata.com/resource/2646-ez2p.json"

      result <- soc_read(url)

      # fmt: skip
      expected <- tibble::tribble(
        ~ domain, ~ name, ~ logo, ~ tags, ~ email,
        "data.seattle.gov", "City of Seattle", NA_character_, "seattle, open data, washington, open government", "open-data@seattle.gov",
        "data.sfgov.org", "City of San Francisco", NA_character_, "san francisco, california, open data", "open-data@sfgov.org"
      )
      attr(expected, "id") <- "2646-ez2p"
      attr(expected, "name") <- "Datasites for APIs.JSON"
      attr(expected, "owner_name") <- "Chris Metcalf (Developer Experience)"
      attr(expected, "provenance") <- "official"
      attr(expected, "created") <- as.POSIXct("2015-01-03 00:13:48", tz = "UTC")
      attr(expected, "data_last_updated") <- as.POSIXct(
        "2015-01-03 00:56:25",
        tz = "UTC"
      )
      attr(expected, "metadata_last_updated") <- as.POSIXct(
        "2015-01-03 00:56:27",
        tz = "UTC"
      )
      attr(expected, "domain_metadata") <- tibble::tibble(
        key = integer(),
        value = logical()
      )
      attr(expected, "columns") <- tibble::tibble(
        column_name = c("domain", "name", "logo", "tags", "email"),
        column_label = c("Domain", "Name", "Logo", "Tags", "Email"),
        column_datatype = c("text", "text", "text", "text", "text")
      )
      attr(expected, "permalink") <- "https://soda.demo.socrata.com/d/2646-ez2p"
      attr(
        expected,
        "link"
      ) <- "https://soda.demo.socrata.com/dataset/Datasites-for-APIs-JSON/2646-ez2p"
      attr(expected, "license") <- NULL

      attr(expected$domain, "label") <- "Domain"
      attr(expected$name, "label") <- "Name"
      attr(expected$logo, "label") <- "Logo"
      attr(expected$tags, "label") <- "Tags"
      attr(expected$email, "label") <- "Email"

      expect_equal(result, expected)
    })

    test_that("soc_read returns sf when there is one spatial col", {
      skip_on_cran()

      url <- "https://soda.demo.socrata.com/resource/6yvf-kk3n.json"

      result <- soc_read(url)

      expect_s3_class(result, "tbl_df")
      expect_s3_class(result, "sf")

      expect_equal(ncol(result), 13)
      expect_equal(nrow(result), 10821)

      expect_equal(
        unique(as.character(sf::st_geometry_type(result$location))),
        "POINT"
      )
      expect_equal(sf::st_crs(result), sf::st_crs(4326))

      expected_cols <- c(
        "source",
        "earthquake_id",
        "version",
        "magnitude",
        "depth",
        "number_of_stations",
        "region",
        "location",
        "location_address",
        "location_city",
        "location_state",
        "location_zip",
        ":@computed_region_k83t_ady5"
      )
      expect_equal(expected_cols, colnames(result))
    })
  },
  simplify = FALSE
)
