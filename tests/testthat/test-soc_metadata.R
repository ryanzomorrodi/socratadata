test_that("soc_metadata_from_tibble", {
  # fmt: skip
  dataset <- tibble::tribble(
    ~ domain, ~ name, ~ logo, ~ tags, ~ email,
    "data.seattle.gov", "City of Seattle", NA_character_, "seattle, open data, washington, open government", "open-data@seattle.gov",
    "data.sfgov.org", "City of San Francisco", NA_character_, "san francisco, california, open data", "open-data@sfgov.org"
  )
  attr(dataset, "soc_meta") <- structure(
    list(
      id = "2646-ez2p",
      name = "Datasites for APIs.JSON",
      attribution = NA_character_,
      attribution_link = NA_character_,
      resource_type = "dataset",
      owner = list(
        id = "8wwb-4vf2",
        display_name = "Chris Metcalf (Developer Experience)"
      ),
      provenance = "official",
      description = NA_character_,
      created = structure(
        1420244028,
        class = c("POSIXct", "POSIXt"),
        tzone = "UTC"
      ),
      published = structure(
        1420246587,
        class = c("POSIXct", "POSIXt"),
        tzone = "UTC"
      ),
      data_last_updated = structure(
        1420246585,
        class = c("POSIXct", "POSIXt"),
        tzone = "UTC"
      ),
      metadata_last_updated = structure(
        1420246587,
        class = c("POSIXct", "POSIXt"),
        tzone = "UTC"
      ),
      domain_category = NA_character_,
      domain_tags = character(0),
      domain_metadata = list(),
      columns = structure(
        list(
          name = c("domain", "name", "logo", "tags", "email"),
          label = c("Domain", "Name", "Logo", "Tags", "Email"),
          description = c(
            NA_character_,
            NA_character_,
            NA_character_,
            NA_character_,
            NA_character_
          ),
          datatype = c("text", "text", "text", "text", "text")
        ),
        class = c("tbl_df", "tbl", "data.frame"),
        row.names = c(NA, 5L)
      ),
      license = NA_character_,
      page_views_total = 399L,
      downloads = 70L,
      permalink = "https://soda.demo.socrata.com/d/2646-ez2p"
    ),
    class = "soc_meta"
  )

  expect_snapshot(print(soc_metadata(dataset)))
})


with_mock_dir(
  "soc_metadata",
  {
    test_that("soc_metadata_from_url", {
      url <- "https://soda.demo.socrata.com/dataset/Datasites-for-APIs-JSON/2646-ez2p"
      object <- soc_metadata(url)
      object$page_views_total <- NULL
      object$downloads <- NULL

      expected <- structure(
        list(
          id = "2646-ez2p",
          name = "Datasites for APIs.JSON",
          attribution = NA_character_,
          attribution_link = NA_character_,
          resource_type = "dataset",
          owner = list(
            id = "8wwb-4vf2",
            display_name = "Chris Metcalf (Developer Experience)"
          ),
          provenance = "official",
          description = NA_character_,
          created = structure(
            1420244028,
            class = c("POSIXct", "POSIXt"),
            tzone = "UTC"
          ),
          published = structure(
            1420246587,
            class = c("POSIXct", "POSIXt"),
            tzone = "UTC"
          ),
          data_last_updated = structure(
            1420246585,
            class = c("POSIXct", "POSIXt"),
            tzone = "UTC"
          ),
          metadata_last_updated = structure(
            1420246587,
            class = c("POSIXct", "POSIXt"),
            tzone = "UTC"
          ),
          domain_category = NA_character_,
          domain_tags = character(0),
          domain_metadata = list(),
          columns = structure(
            list(
              name = c("domain", "name", "logo", "tags", "email"),
              label = c("Domain", "Name", "Logo", "Tags", "Email"),
              description = c(
                NA_character_,
                NA_character_,
                NA_character_,
                NA_character_,
                NA_character_
              ),
              datatype = c("text", "text", "text", "text", "text")
            ),
            class = c("tbl_df", "tbl", "data.frame"),
            row.names = c(NA, 5L)
          ),
          license = NA_character_,
          permalink = "https://soda.demo.socrata.com/d/2646-ez2p"
        ),
        class = "soc_meta"
      )
      expect_equal(object, expected = expected)
    })
  },
  simplify = FALSE
)
