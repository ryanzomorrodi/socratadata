with_mock_dir(
  "soc_read",
  {
    test_that("soc datatype - boolean", {
      url <- "https://soda.demo.socrata.com/dataset/Checkboxen/w8wm-g3qx/about_data"
      object <- soc_read(url, alias = "drop")

      # fmt: skip
      expected <- tibble::tribble(
        ~ text, ~ checkbox,
        "True", TRUE,
        "Null", NA,
        "False", FALSE
      )

      attributes(object) <- attributes(object)[
        names(attributes(object)) %in% names(attributes(expected))
      ]

      expect_equal(object, expected)
    })

    test_that("soc datatype - number", {
      url <- "https://soda.demo.socrata.com/dataset/R-Socrata-Test-Full-replace-dataset/kc76-ybeq/about_data"
      object <- soc_read(url, alias = "drop")

      # fmt: skip
      expected <- tibble::tribble(
        ~ x,  ~ y,
         112,  663,
        -798, -93,
         317, -58,
        -853, -797,
         185,  102
      )

      attributes(object) <- attributes(object)[
        names(attributes(object)) %in% names(attributes(expected))
      ]

      expect_equal(object, expected)
    })

    test_that("soc datatype - fixed timestamp", {
      url <- "https://data.cityofchicago.org/Historic-Preservation/Landmark-Districts/zidz-sdfj/about_data"
      object <- soc_read(url, alias = "drop", soc_query(limit = 10))

      # fmt: skip
      expected <- tibble::tribble(
        ~ district_name,                         ~ designation_date,
        "Old Town Triangle",                     as.POSIXct("1977-09-28 07:00:00", tz = "UTC"),
        "Milwaukee Avenue",                      as.POSIXct("2008-04-09 07:00:00", tz = "UTC"),
        "Astor Street",                          as.POSIXct("1975-12-19 08:00:00", tz = "UTC"),
        "Beverly/Morgan Park Railroad Stations", as.POSIXct("1995-04-15 07:00:00", tz = "UTC"),
        "Black Metropolis-Bronzeville",          as.POSIXct("1998-09-09 07:00:00", tz = "UTC"),
        "Surf-Pine Grove",                       as.POSIXct("2007-07-19 07:00:00", tz = "UTC"),
        "Five Houses on Avers Avenue",           as.POSIXct("1994-03-02 08:00:00", tz = "UTC"),
        "Hawthorne Place",                       as.POSIXct("1996-03-26 08:00:00", tz = "UTC"),
        "Historic Michigan Boulevard",           as.POSIXct("2002-02-27 08:00:00", tz = "UTC"),
        "Hutchinson Street",                     as.POSIXct("1977-08-31 07:00:00", tz = "UTC")
      )

      attributes(object) <- attributes(object)[
        names(attributes(object)) %in% names(attributes(expected))
      ]

      expect_equal(object, expected)
    })

    test_that("soc datatype - floating timestamp", {
      url <- "https://soda.demo.socrata.com/dataset/Live-Earthquakes/jatp-jqxg/about_data"
      object <- soc_read(
        url,
        alias = "drop",
        soc_query(
          select = "time, updated"
        )
      )

      # fmt: skip
      expected <- tibble::tribble(
        ~ time,                            ~ updated,
        as.POSIXct("2013-09-05 22:05:50"), as.POSIXct("2013-09-05 22:19:42"),
        as.POSIXct("2013-09-05 21:57:06"), as.POSIXct("2013-09-05 22:19:21"),
        as.POSIXct("2013-09-05 21:52:35"), as.POSIXct("2013-09-05 22:09:12"),
        as.POSIXct("2013-09-05 21:46:36"), as.POSIXct("2013-09-05 22:08:27"),
        as.POSIXct("2013-09-05 21:32:19"), as.POSIXct("2013-09-05 21:43:53"),
        as.POSIXct("2014-05-05 22:36:44"), as.POSIXct("2014-05-05 22:39:34"),
        as.POSIXct("2014-05-05 22:04:10"), as.POSIXct("2014-05-05 22:24:13"),
        as.POSIXct("2014-05-05 22:03:30"), as.POSIXct("2014-05-05 22:24:15"),
        as.POSIXct("2014-05-05 21:49:43"), as.POSIXct("2014-05-05 22:03:04"),
        as.POSIXct("2014-05-05 21:46:58"), as.POSIXct("2014-05-05 22:24:18")
      )

      # drop metadata
      attributes(object) <- attributes(object)[
        names(attributes(object)) %in% names(attributes(expected))
      ]

      expect_equal(object, expected)
    })

    test_that("soc datatype - text", {
      url <- "https://soda.demo.socrata.com/dataset/Datasites-for-APIs-JSON/2646-ez2p/about_data"
      object <- soc_read(url, alias = "drop")

      # fmt: skip
      expected <- tibble::tribble(
        ~ domain,           ~ name,                  ~ logo,        ~ tags,                                            ~ email,
        "data.seattle.gov", "City of Seattle",       NA_character_, "seattle, open data, washington, open government", "open-data@seattle.gov",
        "data.sfgov.org",   "City of San Francisco", NA_character_, "san francisco, california, open data",            "open-data@sfgov.org"
      )

      attributes(object) <- attributes(object)[
        names(attributes(object)) %in% names(attributes(expected))
      ]

      expect_equal(object, expected)
    })

    test_that("soc datatype - url", {
      url <- "https://soda.demo.socrata.com/dataset/URL-Datatype/7caz-dk9s/about_data"
      object <- soc_read(url, alias = "drop")

      # fmt: skip
      expected <- tibble::tibble(
        url_with_description = tibble::tribble(
          ~ url, ~ description,
          "https://opendata.cityofnewyork.us/", "I'm Description Text!",
          "https://data.sfgov.org/", "I'm Description Text!",
          "https://data.cityofchicago.org/", "I'm Description Text!"
        ),
        url_without_description = tibble::tribble(
          ~ url, ~ description,
          "https://opendata.cityofnewyork.us/", NA_character_,
          "https://data.sfgov.org/", NA_character_,
          "https://data.cityofchicago.org/", NA_character_
        )
      )
      # drop metadata
      attributes(object) <- attributes(object)[
        names(attributes(object)) %in% names(attributes(expected))
      ]

      expect_equal(object, expected)
    })
  },
  simplify = FALSE
)
