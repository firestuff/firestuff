<!--# set var="title" value="Fun with map visualizations" -->
<!--# set var="date" value="March 26, 2010" -->

<!--# include file="include/top.html" -->

I've been playing with Google's [Chart Tools](http://code.google.com/apis/charttools/) quite a bit lately.

I did some internal stuff at work (that unfortunately I can't show here) to visualize problems where you have lots of points, all connected by lines that you know the ideal length of, but where those lengths don't lay out properly in 2 dimensions, and figuring out where to put the points is hard anyway.

The most elegant solution seems to be a [force-directed graph](http://en.wikipedia.org/wiki/Force-based_algorithms): pretend the lines are springs, randomize the initial point positions, and simulate physics iteratively. It's slow, and the algorithm is easy to screw up (don't forget friction, or they just orbit each other), but the results are impressive: consistent layouts that are rotation-agnostic each time you run the algorithm. I ended up rendering the results using the static [scatter chart](http://code.google.com/apis/chart/docs/gallery/scatter_charts.html). Sadly, the URL syntax is arcane, and the error feedback is nonexistent.

Today, I got to build a visualization that [went public](http://www.google.com/appserve/fiberrfi):

<img src="data:image/png;base64,<!--# include file="images/fiberrfi-map.png.base64" -->" alt="">

We had lots of data from the fiber-to-the-home request-for-information site, and needed a way to visualize it. This is a [geo map](http://code.google.com/apis/visualization/documentation/gallery/geomap.html) that uses markers. Unfortunately, the API limits you to 400 points, which wasn't enough, so I (at nmlorg's suggestion) screenshotted the map with 400 points at a time and stitched the results; hacky, but functional. We couldn't have used the direct rendering anyway, as it does one AJAX call to Google Maps to look up each point (we were passing in ZIP codes), so it takes ~10 minutes to render.

We considered [static maps](http://code.google.com/apis/maps/documentation/staticmaps/) (custom icons would've been cool), but the URL length limit makes the effective point limit less than 400, and there's only so much stitching I'll put up with.

<!--# include file="include/bottom.html" -->
