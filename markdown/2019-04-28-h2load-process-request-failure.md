<!--# set var="title" value="h2load Process Request Failure" -->
<!--# set var="date" value="2019-04-28" -->

<!--# include file="include/top.html" -->

I went looking for an HTTP/2 replacement for [Ab](https://httpd.apache.org/docs/2.4/programs/ab.html) and found [h2load](https://nghttp2.org/documentation/h2load-howto.html). Perfect, awesome, just what I need. My first few test runs work fine, then as I'm ramping up test size...

	Process Request Failure:1                                                                                                            
That number at the end seems to be the number of failed requests. Tellingly, it happened after exactly 1000 successful requests each time. Restart h2load, get another 1000 successful requests. I tried `keepalive_requests` in my nginx config, but no luck. Finally, after going through the nginx source for instances of "1000", I found [`http2_max_requests`](https://nginx.org/en/docs/http/ngx_http_v2_module.html#http2_max_requests), which defaults to 1000. Increase that to an enormous number, restart nginx, everything works fine.

Someone should really implement reconnect in h2load, or at least some decent error messages.

<!--# include file="include/bottom.html" -->
