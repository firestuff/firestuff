<!--# set var="title" value="In praise of blame" -->
<!--# set var="date" value="2019-11-25" -->

<!--# include file="include/top.html" -->

I review a large number of postmortem docs, and I’m responsible for improving the value that we take from the postmortem process. Among many observations, I was considering two common ones:

1. “Blameless”, a word that precedes “postmortem” in conversation about half the time (thanks [SRE book](https://landing.google.com/sre/sre-book/chapters/postmortem-culture/)), is taken to mean “anonymous” (note that “blame” can be used to mean identification (`git blame`) or identification _and_ shaming). This tends to turn timelines into piles of convoluted passive voice, e.g. “A command was executed that deleted....”.
2. The analysis addresses only the proximate cause and perhaps one or two minor related items like monitoring tweaks. It fails to delve in to the processes/culture that led to the issue being introduced, defense in depth strategies for preventing future issues in the same class, or other systems that might have similar issues or would benefit from proactive protection from introducing them.

Both of these seem to correlate with more junior teams that are new to the postmortem process, are not confident in their product quality, or both. The reasons for these seem pretty obvious: team members are afraid that they’ll be shamed for failure, and the process of thinking beyond the proximate cause takes practice to learn.

## What if blamelessness and shallow analysis are related?
The process of expanding the scope of review and followups almost certainly expands the scope of those who had some involvement in the systems discussed, and who therefore might be blamed. Fear of individual consequences from an outage seems likely to cause individuals to avoid contributing to the expansion of scope of a postmortem, lest they take some of the blame. The mechanical act of anonymizing the postmortem even becomes harder with greater scope.

In contrast, really great postmortems are covered in names. The review process has senior people throwing themselves in for code they wrote three years ago that might have prevented the issue if they’d just had a crystal ball. I’ve had to do editing in the past of postmortems for major outages where some of the related cause list was so outlandish that it actually distracted from the discussion. There doesn’t seem to be much middle ground — either a postmortem is narrow and relatively anonymous, or is broad and very clear about contributors.

## Is anyone really blameless?
Consider this hypothetical situation: An SRE makes a mistake and causes an outage. They’ve previously caused the same type of outage and written a postmortem for it. There are technical safeguards in place which they bypassed on the way to causing the outage. The technical safeguards don’t slow down the process unduly; others on the team operate on the safe path and are happy with it. The team isn’t under undue stress or time constraints. This SRE has caused many more outages than their peers, without a correspondingly higher productive contribution rate.

Do you blame this person? The answer is probably yes, _and that’s OK_.

Ask yourself: how does this differ from cases that I believe should be blameless?

The conclusion I came to is something like the [Reasonable Person Standard](https://en.wikipedia.org/wiki/Reasonable_person), which I’ll call the “Reasonable SRE Standard”. We expect our SRE peers to:

1. Be reachable and involved when reasonably expected to be, e.g. when oncall.
2. Leverage the basic knowledge that we expect of an SRE for the reasonable avoidance of outages.
3. Scale their level of care and precaution with the severity of consequences that can be reasonably anticipated.
4. Learn from their own mistakes and those of their peers within a reasonable radius (e.g. reading postmortems from those in the same oncall rotation).
5. Communicate clearly when they have reasonable belief that they caused an issue, or belief they can help solve or root cause it.

There are probably other items that could be added to this list. The standard is fuzzy and somewhat circular (it defines “reasonable” with “reasonable”), just like the legal standard. Every team will interpret it differently. It’s intended as a conversation starting point, especially for SRE managers and tech leads.

## Blameful Postmortems
If we admit that the postmortem process _can_ result in blame, how do we reconcile that with a culture where we’d like individuals to be comfortable transparently discussing issues? The answer lies in the separation of blame and shame. Consider the example of the good postmortem from above: there’s plenty of blame, but it’s _spread widely_. Everyone involved with some precursor of the outage implicitly admits blame: the dev team who shipped a product that caused more alerts, the SRE manager who didn’t push back enough, the person who didn’t write a related test, the person who hasn’t finished the monitoring improvements, etc. Everyone involved is reasonable, and everyone involved shares some of the blame, and that’s fine — that’s the job, and no one will be shamed for it.

If there is enough blame, shaming based on the blame becomes either infeasible or obviously arbitrary.

I propose a new goal for postmortems: as much blame as possible. The goal of the author should be to find as many causes, and as many people, to blame as they possibly can. This aligns with the goal of deep postmortems much better than the blamelessness goal. We all get to stop dancing around the fact that we know we can’t really reach blamelessness, and instead embrace blame. In this proposed world, shallow postmortems are implicitly discouraged because they look like the hypothetical example above where one person really does deserve individual fault. That’s the exception, though, and the reality is that most postmortems become an exercise in shared ownership, which hopefully extends to the learnings from them.

<!--# include file="include/bottom.html" -->
