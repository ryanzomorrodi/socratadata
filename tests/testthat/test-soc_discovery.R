with_mock_dir(
  "soc_discovery",
  {
    test_that("attribution", {
      datasets <- soc_discover(attribution = "City of Chicago", limit = 10)

      expect_gte(nrow(datasets), 1)
    })

    test_that("categories", {
      datasets <- soc_discover(
        categories = c("transportation", "economy"),
        limit = 10
      )

      expect_gte(nrow(datasets), 1)
    })

    test_that("domain_categories", {
      expect_error(soc_discover(domain_category = "Transportation"))

      datasets <- soc_discover(
        domains = "data.cityofchicago.org",
        domain_category = "Transportation",
        limit = 10
      )

      expect_gte(nrow(datasets), 1)
    })

    test_that("domains", {
      datasets <- soc_discover(
        domains = c("data.cityofchicago.org", "data.ny.gov"),
        limit = 10
      )

      expect_gte(nrow(datasets), 1)
    })

    test_that("ids", {
      datasets <- soc_discover(ids = c("zidz-sdfj", "xzkq-xp2w"))

      expect_equal(nrow(datasets), 2)
    })

    test_that("names", {
      datasets <- soc_discover(
        names = c(
          "Current Employee Names, Salaries, and Position Titles",
          "Landmark Districts"
        ),
        limit = 10
      )

      expect_gte(nrow(datasets), 1)
    })

    test_that("only", {
      datasets <- soc_discover(
        only = c("dataset", "story"),
        limit = 10
      )

      expect_gte(nrow(datasets), 1)
    })

    test_that("provenance", {
      datasets <- soc_discover(
        provenance = "official",
        limit = 10
      )

      expect_gte(nrow(datasets), 1)
    })

    test_that("query", {
      datasets <- soc_discover(
        query = "bus",
        limit = 10
      )

      expect_gte(nrow(datasets), 1)
    })

    test_that("domain_tags", {
      expect_error(soc_discover(domain_tags = c("cta", "public transit")))

      datasets <- soc_discover(
        domains = "data.cityofchicago.org",
        domain_tags = c("cta", "public transit"),
        limit = 10
      )

      expect_gte(nrow(datasets), 1)
    })

    test_that("location", {
      datasets <- soc_discover(
        location = "eu",
        limit = 10
      )

      expect_gte(nrow(datasets), 1)
    })
  },
  simplify = FALSE
)
