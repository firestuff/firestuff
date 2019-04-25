<!--# set var="title" value="apt caching for debootstrap" -->
<!--# set var="date" value="2016-04-02" -->

<!--# include file="include/top.html" -->

If you’re building system images, you’re going to do a lot of debootstrap, which is going to fetch a lot of packages. On a fast system, that’ll be the slowest part of the process. Here’s how to cache.

## Install apt-cacher-ng

    sudo apt-get install squid-deb-proxy

## Tell programs to use the proxy

    export http_proxy=http://127.0.0.1:8000
    # Note that you'll need to re-export this before any use of debootstrap

## Tell sudo to pass through http\_proxy

    sudo visudo
    # Add the line after the env_reset line:
    Defaults env_keep += "http_proxy"

<!--# include file="include/bottom.html" -->
