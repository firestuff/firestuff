<!--# set var="title" value="Net Neutrality?" -->
<!--# set var="date" value="August 22, 2010" -->

<!--# include file="include/top.html" -->

A few weeks ago, Google announced a [starting point framework for discussion of net neutrality](http://googlepublicpolicy.blogspot.com/2010/08/joint-policy-proposal-for-open-internet.html). It's been attacked from all sides for lots of reasons. I was having trouble forming an opinion in any direction (other than some knee-jerk Google defense), until I read [this](http://www.reddit.com/r/AskReddit/comments/d2kwy/reddit_what_the_heck_is_net_neutrality/). It made me realize that the problem with the Google proposal isn't specific stances, but lack of technical detail; it makes it hard for technical people to have a rational discussion about this. Even the reddit post doesn't spell this out wonderfully.

Instead, how about some simple (technical) questions? My personal opinions are in []. Note "may" instead of "can"; all of these things are technically possible today (which is how we got here), so we're talking about industry self-regulation or government regulation.

1. **May ISPs prioritize some protocols over others?** [yes]<br>
   e.g. *may an ISP give HTTP traffic priority over bittorrent?*
   1. **Must users be able to change these settings, including disabling prioritization?** [yes]<br>
      This may be a tricky network architecture problem if the ISP has choke points that aren't the DSL or cable line. If the ISP oversubscribes their own upstream links, they have to propagate the user preference through the whole network.
      1. **Is it opt-in or opt-out?** [opt-out; this is probably useful for most users]
   1. **May prioritization consider sub-protocols?** [yes]<br>
      e.g. *may an ISP give text/html HTTP responses priority over video/webm responses?*

1. **May ISPs prioritize some destinations over others?** [no]<br>
   e.g. *may an ISP give google.com traffic priority over bing.com traffic?*<br>
   User choice probably doesn't make sense here, as it's hard to argue that this type of prioritization benefits users.
   1. **May ISPs accept money from destination sites for prioritization?** [no]<br>
      e.g. *may Verizon take $10 million/year from Google to prioritize traffic to google.com?*

1. **May ISPs prioritize some users over others?** [yes]<br>
   e.g. *may an ISP provide more expensive service options that prioritize traffic?*
   1. **May ISPs prioritize users punitively?** [no]<br>
      e.g. *may an ISP move a high-traffic user to a lower priority?*

1. **May ISPs block some protocols?** [no]<br>
   e.g. *may an ISP block bittorrent entirely?*<br>
   This typically comes up as an anti-piracy solution. [Protocols themselves are never inherently anti-copyright (even if 95% of their use is for software/media piracy); the courts get this one wrong frighteningly often.]

1. **May ISPs block some destinations?** [no]<br>
   e.g. *may an ISP block porn sites?*<br>
   This typically comes up as a protect-the-children solution. [Filtering technology has far too many false positives, and the same technology available to ISPs is available to end users. Parents concerned about what their children are exposed to can install home solutions, which children will bypass just as easily as they bypass ISP solutions.]

1. **May ISPs charge per-byte?** [yes]<br>
   e.g. *may ISPs offer cheaper plans that charge per-megabyte, possibly after the user passes a threshold?*<br>
   1. **Must ISPs provide per-byte users tools to see their usage?** [yes]
   1. **Must ISPs only use the word "unlimited" for plans which are truly unlimited?** [yes]<br>
      e.g. *are ISPs prohibited from calling a plan with a 250GB cap "unlimited" in advertising?*

1. **Must ISPs disclose their answers to all of these questions?** [yes]<br>
   e.g. *"We prioritize some destinations over others."*
   1. **Must ISPs disclose details?** [yes]<br>
      e.g. *"We prioritize google.com over bing.com."*

<!--# include file="include/bottom.html" -->
