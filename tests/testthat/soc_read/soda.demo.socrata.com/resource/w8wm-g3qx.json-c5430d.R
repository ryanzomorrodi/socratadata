structure(list(method = "GET", url = "https://soda.demo.socrata.com/resource/w8wm-g3qx.json?%24limit=10000", 
    status_code = 200L, headers = structure(list(Server = "nginx", 
        Date = "Tue, 22 Jul 2025 20:42:08 GMT", `Content-Type` = "application/json;charset=utf-8", 
        `Transfer-Encoding` = "chunked", Connection = "keep-alive", 
        `Access-Control-Allow-Origin` = "*", ETag = "\"Zm94dHJvdC41NjgxNV8yXzE1ODBVUm5jMktjTUxiWkNPYXFlNFFZVGl4YXFn--gzihxRgOpWYpOBBhHa8X8dfBzKwcas---gzip\"", 
        `X-SODA2-Fields` = "[\"text\",\"checkbox\"]", `X-SODA2-Types` = "[\"text\",\"boolean\"]", 
        `X-SODA2-Data-Out-Of-Date` = "false", `X-SODA2-Truth-Last-Modified` = "Fri, 02 Dec 2016 17:45:50 GMT", 
        `X-SODA2-Secondary-Last-Modified` = "Fri, 02 Dec 2016 17:45:50 GMT", 
        `Last-Modified` = "Fri, 02 Dec 2016 17:45:50 GMT", Vary = "Accept-Encoding", 
        `Content-Encoding` = "gzip", Age = "0", `X-Socrata-Region` = "aws-us-east-1-fedramp-prod", 
        `Strict-Transport-Security` = "max-age=31536000; includeSubDomains", 
        `X-Socrata-RequestId` = "53813ca037513071f8bd3b347aadd847"), class = "httr2_headers"), 
    body = charToRaw("[{\"text\":\"True\",\"checkbox\":true}\n,{\"text\":\"Null\"}\n,{\"text\":\"False\",\"checkbox\":false}]\n"), 
    timing = c(redirect = 0, namelookup = 1.2e-05, connect = 0, 
    pretransfer = 5.7e-05, starttransfer = 0.120935, total = 0.121013
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
