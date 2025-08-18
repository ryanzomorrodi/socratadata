with_mock_dir(
  "soc_query",
  {
    test_that("select", {
      url <- "https://soda.demo.socrata.com/dataset/All-OBE-Column-Types/2asz-g9qq/about_data"
      args <- list(
        url,
        alias = "drop",
        soc_query(select = "plain_text_column, formatted_text_column as html"),
        include_synthetic_cols = FALSE
      )
      expected <- tibble::tibble(
        plain_text_column = "Sample Text",
        html = "<p>Sample <strong>Rich Text</strong></p>"
      )

      "v2"
      with_mocked_bindings(
        code = {
          object_v2 <- suppressMessages(do.call(soc_read, args)) |>
            limit_attr_to_expected(expected)
        },
        Sys_get_env = function(envvar) NULL
      )
      expect_equal(object_v2, expected)

      "v3"
      skip_if_no_api_key()
      object_v3 <- do.call(soc_read, args) |>
        limit_attr_to_expected(expected)
      expect_equal(object_v3, expected)
    })

    test_that("where", {
      url <- "https://soda.demo.socrata.com/dataset/My-super-awesome-Earthquakes-dataset/4tka-6guv/about_data"
      args <- list(
        url,
        alias = "drop",
        soc_query(where = "depth > 635"),
        include_synthetic_cols = FALSE
      )
      expected <- tibble::tibble(
        source = "us",
        earthquake_id = "usb000qd0j",
        version = NA_character_,
        magnitude = 4.7,
        depth = 635.78,
        number_of_stations = NA_real_,
        region = "59km SW of Ndoi Island, Fiji",
        location = tibble::tibble(
          geometry = sf::st_sfc(
            sf::st_point(),
            crs = sf::st_crs(4326)
          ),
          address = NA_character_,
          city = NA_character_,
          state = NA_character_,
          zip = NA_character_
        )
      )

      "v2"
      with_mocked_bindings(
        code = {
          object_v2 <- suppressMessages(do.call(soc_read, args)) |>
            limit_attr_to_expected(expected)
        },
        Sys_get_env = function(envvar) NULL
      )
      expect_equal(object_v2, expected)

      "v3"
      skip_if_no_api_key()
      object_v3 <- do.call(soc_read, args) |>
        limit_attr_to_expected(expected)
      expect_equal(object_v3, expected)
    })

    test_that("group_by", {
      url <- "https://soda.demo.socrata.com/dataset/My-super-awesome-Earthquakes-dataset/4tka-6guv/about_data"
      args <- list(
        url,
        alias = "drop",
        soc_query(
          select = "magnitude, count(*) as count",
          where = "magnitude > 6",
          group_by = "magnitude"
        ),
        include_synthetic_cols = FALSE
      )
      expected <- tibble::tibble(
        magnitude = c(6.1, 6.2, 6.4, 6.5, 6.6),
        count = c(6, 4, 1, 2, 4)
      )

      "v2"
      with_mocked_bindings(
        code = {
          object_v2 <- suppressMessages(do.call(soc_read, args)) |>
            limit_attr_to_expected(expected)
        },
        Sys_get_env = function(envvar) NULL
      )
      expect_equal(object_v2, expected)

      "v3"
      skip_if_no_api_key()
      object_v3 <- do.call(soc_read, args) |>
        limit_attr_to_expected(expected)
      expect_equal(object_v3, expected)
    })

    test_that("having", {
      url <- "https://soda.demo.socrata.com/dataset/My-super-awesome-Earthquakes-dataset/4tka-6guv/about_data"
      args <- list(
        url,
        alias = "drop",
        soc_query(
          select = "magnitude, count(*) as count",
          group_by = "magnitude",
          having = "count > 400",
          order_by = "count"
        ),
        include_synthetic_cols = FALSE
      )
      expected <- tibble::tibble(
        magnitude = c(0.9, 1.4, 1.3, 1, 1.2, 1.1),
        count = c(405, 422, 467, 485, 492, 537)
      )

      "v2"
      with_mocked_bindings(
        code = {
          object_v2 <- suppressMessages(do.call(soc_read, args)) |>
            limit_attr_to_expected(expected)
        },
        Sys_get_env = function(envvar) NULL
      )
      expect_equal(object_v2, expected)

      "v3"
      skip_if_no_api_key()
      object_v3 <- do.call(soc_read, args) |>
        limit_attr_to_expected(expected)
      expect_equal(object_v3, expected)
    })

    test_that("order_by", {
      url <- "https://soda.demo.socrata.com/dataset/My-super-awesome-Earthquakes-dataset/4tka-6guv/about_data"
      args <- list(
        url,
        alias = "drop",
        soc_query(
          select = "magnitude, count(*) as count",
          group_by = "magnitude",
          having = "count > 400",
          order_by = "count"
        ),
        include_synthetic_cols = FALSE
      )
      expected <- tibble::tibble(
        magnitude = c(0.9, 1.4, 1.3, 1, 1.2, 1.1),
        count = c(405, 422, 467, 485, 492, 537)
      )

      "v2"
      with_mocked_bindings(
        code = {
          object_v2 <- suppressMessages(do.call(soc_read, args)) |>
            limit_attr_to_expected(expected)
        },
        Sys_get_env = function(envvar) NULL
      )
      expect_equal(object_v2, expected)

      "v3"
      skip_if_no_api_key()
      object_v3 <- do.call(soc_read, args) |>
        limit_attr_to_expected(expected)
      expect_equal(object_v3, expected)
    })

    test_that("limit", {
      url <- "https://soda.demo.socrata.com/dataset/My-super-awesome-Earthquakes-dataset/4tka-6guv/about_data"
      args <- list(
        url,
        alias = "drop",
        soc_query(select = "source", limit = 10, order_by = "source"),
        include_synthetic_cols = FALSE
      )
      expected <- tibble::tibble(
        source = c("ak", "ak", "ak", "ak", "ak", "ak", "ak", "ak", "ak", "ak")
      )

      "v2"
      with_mocked_bindings(
        code = {
          object_v2 <- suppressMessages(do.call(soc_read, args)) |>
            limit_attr_to_expected(expected)
        },
        Sys_get_env = function(envvar) NULL
      )
      expect_equal(object_v2, expected)

      "v3"
      skip_if_no_api_key()
      object_v3 <- do.call(soc_read, args) |>
        limit_attr_to_expected(expected)
      expect_equal(object_v3, expected)
    })
  },
  simplify = FALSE
)
