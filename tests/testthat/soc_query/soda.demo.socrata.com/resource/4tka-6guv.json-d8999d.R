structure(list(method = "GET", url = "https://soda.demo.socrata.com/resource/4tka-6guv.json?%24select=magnitude%2C%20count%28%2A%29%20as%20count&%24group=magnitude&%24having=count%20%3E%20400&%24order=count&%24limit=10000&%24offset=10000", 
    status_code = 200L, headers = structure(list(Server = "nginx", 
        Date = "Mon, 14 Jul 2025 16:01:26 GMT", `Content-Type` = "application/json;charset=utf-8", 
        `Transfer-Encoding` = "chunked", Connection = "keep-alive", 
        `Access-Control-Allow-Origin` = "*", ETag = "\"Zm94dHJvdC4zMzQxMl80XzEyMjdIWFFHVDhXTVdxeXNCVHlTUjJnNG54ZmxHMA-nWvA7q7xWKRsjUTbWcbX7KudNM4--gzip--gzip\"", 
        `X-SODA2-Fields` = "[\"magnitude\",\"count\"]", `X-SODA2-Types` = "[\"number\",\"number\"]", 
        `X-SODA2-Data-Out-Of-Date` = "false", `X-SODA2-Truth-Last-Modified` = "Wed, 04 Sep 2019 17:25:46 GMT", 
        `X-SODA2-Secondary-Last-Modified` = "Wed, 04 Sep 2019 17:25:46 GMT", 
        `Last-Modified` = "Wed, 04 Sep 2019 17:25:46 GMT", Vary = "Accept-Encoding", 
        `Content-Encoding` = "gzip", Age = "0", `X-Socrata-Region` = "aws-us-east-1-fedramp-prod", 
        `Strict-Transport-Security` = "max-age=31536000; includeSubDomains", 
        `X-Socrata-RequestId` = "e1a6a3cff5a0c4d66a6d5aba724a60bb"), class = "httr2_headers"), 
    body = charToRaw("[]\n"), timing = c(redirect = 0, namelookup = 1.3e-05, 
    connect = 0, pretransfer = 4.5e-05, starttransfer = 0.108189, 
    total = 0.108285), cache = new.env(parent = emptyenv())), class = "httr2_response")
