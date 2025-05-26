with_mock_dir(
  "soc_read",
  {
    test_that("soc_read returns tibble when no spatial cols", {
      skip_on_cran()

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
      attr(expected, "created") <- as.POSIXct("2015-01-03 00:13:48", tz = "UTC")
      attr(expected, "data_last_updated") <- as.POSIXct(
        "2015-01-03 00:56:25",
        tz = "UTC"
      )
      attr(expected, "metadata_last_updated") <- as.POSIXct(
        "2015-01-03 00:56:27",
        tz = "UTC"
      )
      attr(expected, "description") <- character()
      attr(expected$domain, "label") <- "Domain"
      attr(expected$name, "label") <- "Name"
      attr(expected$logo, "label") <- "Logo"
      attr(expected$tags, "label") <- "Tags"
      attr(expected$email, "label") <- "Email"
      attr(expected$domain, "description") <- NA_character_
      attr(expected$name, "description") <- NA_character_
      attr(expected$logo, "description") <- NA_character_
      attr(expected$tags, "description") <- NA_character_
      attr(expected$email, "description") <- NA_character_
      class(expected) <- c("soc_tbl", "tbl_df", "tbl", "data.frame")

      expect_equal(result, expected)
    })

    test_that("soc_read returns sf when there is one spatial col", {
      skip_on_cran()

      url <- "https://soda.demo.socrata.com/resource/6yvf-kk3n.json"

      result <- soc_read(url)

      expect_s3_class(result, "soc_tbl")
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

      # Check metadata
      expect_equal(attr(result, "id"), "4tka-6guv")
      expect_equal(attr(result, "name"), "My super awesome Earthquakes dataset")
      expect_equal(
        attr(result, "created"),
        as.POSIXct("2012-09-14 22:59:33", tz = "UTC")
      )
      expect_equal(
        attr(result, "data_last_updated"),
        as.POSIXct("2016-05-02 17:18:30", tz = "UTC")
      )
      expect_equal(
        attr(result, "metadata_last_updated"),
        as.POSIXct("2016-09-02 22:13:32", tz = "UTC")
      )
      expect_equal(
        attr(result, "description"),
        "Real-time, worldwide earthquake list for the past 7 days (not actually real-time)"
      )
    })
  },
  simplify = FALSE
)
