function(response) {
  # turn the api 3 link into the permalink
  httptest2::gsub_response(
    response,
    "api/v3/views/([a-z0-9]{4}-[a-z0-9]{4})/query.json$",
    "d/\\1"
  )
}
