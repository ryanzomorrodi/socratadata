structure(list(method = "GET", url = "https://soda.demo.socrata.com/resource/4tka-6guv.json?%24select=magnitude%2C%20count%28%2A%29%20as%20count&%24group=magnitude&%24having=count%20%3E%20400&%24limit=10000", 
    status_code = 200L, headers = structure(list(Server = "nginx", 
        Date = "Tue, 22 Jul 2025 20:42:05 GMT", `Content-Type` = "application/json;charset=utf-8", 
        `Transfer-Encoding` = "chunked", Connection = "keep-alive", 
        `Access-Control-Allow-Origin` = "*", ETag = "\"Zm94dHJvdC4zMzQxMl80XzEyMjB0ZmJKQWpDWGhGY0JVbElkTl9yRmwxQzlSQQ-tVdC22VAZlOO8l8cybN0OVhIMKE--gzip--gzip\"", 
        `X-SODA2-Fields` = "[\"magnitude\",\"count\"]", `X-SODA2-Types` = "[\"number\",\"number\"]", 
        `X-SODA2-Data-Out-Of-Date` = "false", `X-SODA2-Truth-Last-Modified` = "Wed, 04 Sep 2019 17:25:46 GMT", 
        `X-SODA2-Secondary-Last-Modified` = "Wed, 04 Sep 2019 17:25:46 GMT", 
        `Last-Modified` = "Wed, 04 Sep 2019 17:25:46 GMT", Vary = "Accept-Encoding", 
        `Content-Encoding` = "gzip", Age = "0", `X-Socrata-Region` = "aws-us-east-1-fedramp-prod", 
        `Strict-Transport-Security` = "max-age=31536000; includeSubDomains", 
        `X-Socrata-RequestId` = "e3acb9b0b20c844d50cab57131889547"), class = "httr2_headers"), 
    body = charToRaw("[{\"magnitude\":\"1.4\",\"count\":\"422\"}\n,{\"magnitude\":\"0.9\",\"count\":\"405\"}\n,{\"magnitude\":\"1\",\"count\":\"485\"}\n,{\"magnitude\":\"1.1\",\"count\":\"537\"}\n,{\"magnitude\":\"1.2\",\"count\":\"492\"}\n,{\"magnitude\":\"1.3\",\"count\":\"467\"}]\n"), 
    timing = c(redirect = 0, namelookup = 2.5e-05, connect = 0, 
    pretransfer = 9.3e-05, starttransfer = 0.27481, total = 0.274903
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
