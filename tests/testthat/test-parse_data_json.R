test_that("parse boolean as logical", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["col"]',
      "X-SODA2-Types" = '["boolean"]'
    ),
    body = charToRaw('[{"col": true}, {"col": false}, {}]')
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(result$col, c(TRUE, FALSE, NA))
})

test_that("parse number as double", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["col"]',
      "X-SODA2-Types" = '["number"]'
    ),
    body = charToRaw('[{"col": "42.5"}, {"col": "-7.1"}, {}]')
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(result$col, c(42.5, -7.1, NA))
})

test_that("parse fixed_timestamp as UTC POSIXct", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["col"]',
      "X-SODA2-Types" = '["fixed_timestamp"]'
    ),
    body = charToRaw(
      '[
        {"col": "2014-10-13T00:00:00.000Z"}, 
        {"col": "2021-06-15T13:45:30.123Z"}, 
        {}
      ]'
    )
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(
    result$col,
    as.POSIXct(
      c(
        "2014-10-13T00:00:00.000Z",
        "2021-06-15T13:45:30.123Z",
        NA
      ),
      format = "%Y-%m-%dT%H:%M:%S",
      tz = "UTC"
    )
  )
})

test_that("parse floating_timestamp as local POSIXct", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["col"]',
      "X-SODA2-Types" = '["floating_timestamp"]'
    ),
    body = charToRaw(
      '[
        {"col": "2014-10-13T00:00:00.000"},
        {"col": "2021-06-15T13:45:30.123"},
        {}
      ]'
    )
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(
    result$col,
    as.POSIXct(
      c(
        "2014-10-13T00:00:00.000",
        "2021-06-15T13:45:30.123",
        NA
      ),
      format = "%Y-%m-%dT%H:%M:%S"
    )
  )
})

test_that("parse text as character", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["col"]',
      "X-SODA2-Types" = '["text"]'
    ),
    body = charToRaw('[{"col": "hello"}, {"col": "world"}, {}]')
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(result$col, c("hello", "world", NA))
})

test_that("parse url as list with url vector and description vector", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["col"]',
      "X-SODA2-Types" = '["url"]'
    ),
    body = charToRaw(
      '[
        {"col": {"url": "http://example.com", "description": "Example site"}},
        {"col": {"url": "http://another.com"}}, 
        {"col": {"description": "forgot the website"}}
      ]'
    )
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(
    result$col,
    tibble::tibble(
      url = c("http://example.com", "http://another.com", NA),
      description = c("Example site", NA, "forgot the website")
    )
  )
})

test_that("parse point as point sfc", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["col"]',
      "X-SODA2-Types" = '["point"]'
    ),
    body = charToRaw(
      '[
        {"col": {"type": "Point", "coordinates": [-87.653274, 41.936172]}}, 
        {"col": {"type": "Point", "coordinates": [-87.629798, 41.878114]}}, 
        {}
      ]'
    )
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(
    result$col,
    sf::st_sfc(
      sf::st_point(c(-87.653274, 41.936172)),
      sf::st_point(c(-87.629798, 41.878114)),
      sf::st_point(),
      crs = sf::st_crs(4326)
    )
  )
})

test_that("parse linestring as linestring sfc", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["col"]',
      "X-SODA2-Types" = '["line"]'
    ),
    body = charToRaw(
      '[
        {"col": {"type": "LineString", "coordinates": [[-87.6, 41.9], [-87.7, 41.95]]}},
        {"col": {"type": "LineString", "coordinates": [[-87.65, 41.88], [-87.66, 41.89]]}},
        {}
      ]'
    )
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(
    result$col,
    sf::st_sfc(
      sf::st_linestring(matrix(c(-87.6, -87.7, 41.9, 41.95), ncol = 2)),
      sf::st_linestring(matrix(c(-87.65, -87.66, 41.88, 41.89), ncol = 2)),
      sf::st_linestring(),
      crs = sf::st_crs(4326)
    )
  )
})

test_that("parse polygon as polygon sfc", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["col"]',
      "X-SODA2-Types" = '["polygon"]'
    ),
    body = charToRaw(
      '[
        {"col": {"type": "Polygon", "coordinates": [[[-87.6, 41.9], [-87.7, 41.9], [-87.7, 41.95], [-87.6, 41.95], [-87.6, 41.9]]]}}, 
        {}
      ]'
    )
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(
    result$col,
    sf::st_sfc(
      sf::st_polygon(list(matrix(
        c(-87.6, -87.7, -87.7, -87.6, -87.6, 41.9, 41.9, 41.95, 41.95, 41.9),
        ncol = 2
      ))),
      sf::st_polygon(),
      crs = sf::st_crs(4326)
    )
  )
})

test_that("parse multipoint as multipoint sfc", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["col"]',
      "X-SODA2-Types" = '["multipoint"]'
    ),
    body = charToRaw(
      '[
        {"col": {"type": "MultiPoint", "coordinates": [[-87.6, 41.9], [-87.7, 41.95]]}}, 
        {}
      ]'
    )
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(
    result$col,
    sf::st_sfc(
      sf::st_multipoint(matrix(c(-87.6, -87.7, 41.9, 41.95), ncol = 2)),
      sf::st_multipoint(),
      crs = sf::st_crs(4326)
    )
  )
})

test_that("parse multilinestring as multilinestring sfc", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["col"]',
      "X-SODA2-Types" = '["multiline"]'
    ),
    body = charToRaw(
      '[
        {"col": {"type": "MultiLineString", "coordinates": [[[1, 2], [3, 4]], [[5, 6], [7, 8]]]}},
        {}
      ]'
    )
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(
    result$col,
    sf::st_sfc(
      sf::st_multilinestring(list(
        matrix(c(1, 3, 2, 4), ncol = 2),
        matrix(c(5, 7, 6, 8), ncol = 2)
      )),
      sf::st_multilinestring(),
      crs = sf::st_crs(4326)
    )
  )
})

test_that("parse multipolygon as multipolygon sfc", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["col"]',
      "X-SODA2-Types" = '["multipolygon"]'
    ),
    body = charToRaw(
      '[
        {"col": {"type": "MultiPolygon", "coordinates": [[[[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]]]]}}, 
        {}
      ]'
    )
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(
    result$col,
    sf::st_sfc(
      sf::st_multipolygon(list(list(matrix(
        c(0, 1, 1, 0, 0, 0, 0, 1, 1, 0),
        ncol = 2
      )))),
      sf::st_multipolygon(),
      crs = sf::st_crs(4326)
    )
  )
})

test_that("parse multiple types", {
  resps <- list(httr2::response(
    status_code = 200,
    headers = list(
      "Content-Type" = "application/json",
      "X-SODA2-Fields" = '["bool_col", "num_col", "text_col", "timestamp_col", "url_col", "geom_col"]',
      "X-SODA2-Types" = '["boolean", "number", "text", "fixed_timestamp", "url", "point"]'
    ),
    body = charToRaw(
      '[
        {
          "bool_col": true,
          "num_col": "3.14",
          "text_col": "pi",
          "timestamp_col": "2023-01-01T00:00:00",
          "url_col": {"url": "https://pi.com", "description": "Pi website"},
          "geom_col": {"type": "Point", "coordinates": [-87.6, 41.9]}
        },
        {
          "bool_col": false,
          "num_col": "-2.71",
          "text_col": "e",
          "timestamp_col": "2023-02-01T12:00:00",
          "url_col": {"url": "https://e.org"},
          "geom_col": {"type": "Point", "coordinates": [-87.7, 41.95]}
        },
        {
          "text_col": "missing everything else",
          "url_col": {"description": "no url"},
          "geom_col": {}
        }
      ]'
    )
  ))

  result <- parse_data_resps(resps, "", Sys.timezone())
  expect_equal(result$bool_col, c(TRUE, FALSE, NA))
  expect_equal(result$num_col, c(3.14, -2.71, NA_real_), tolerance = 1e-6)
  expect_equal(result$text_col, c("pi", "e", "missing everything else"))
  expect_s3_class(result$timestamp_col, "POSIXct")
  expect_equal(
    result$url_col,
    tibble::tibble(
      url = c("https://pi.com", "https://e.org", NA),
      description = c("Pi website", NA, "no url")
    )
  )
  expect_equal(
    result$geom_col,
    sf::st_sfc(
      sf::st_point(c(-87.6, 41.9)),
      sf::st_point(c(-87.7, 41.95)),
      sf::st_point(),
      crs = sf::st_crs(4326)
    )
  )
})
