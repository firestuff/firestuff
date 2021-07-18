<!--# set var="title" value="Elegant expandable elements" -->
<!--# set var="date" value="2021-07-18" -->

<!--# include file="include/top.html" -->

Expandable elements are ubiquitous and seem like they should be pretty simple: click to expand, click to hide/collapse. End of discussion. <beat> Now let’s look at the nuances.

## Tabular Data
Tree-structured tabular data is a nice way to squeeze in an additional visualization dimension. When that tree gets too large, add collapse/expand! The problem is table layout: expanding and collapsing shouldn’t shift columns around. If you implement hide/collapse with the naive `display: none` approach, that shifting is exactly what happens. Fortunately, this has a purpose-built solution: `visibility: collapse` ([MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/visibility)). It hides elements (most often `tr`) while still factoring those elements in to table layout.

## Subtree Memory
Imagine you have a 3-level nested layout, A -> B -> C, with all of them expanded. You collapse A; B and C hide. You expand A; B and C appear. Now you collapse B, hiding C, so only A -> B are visible. Now collapse and expand A again. C should remain hidden. Hidden subtree elements need a “memory” of their state to render correctly when they become visible again.

You might hope to keep this memory using the DOM. Something like nested `tbody` tags would work, but they’re not officially nestable.

Here’s the trick: you already have some UI element to control expansion, which presumably changes its appearance when a subtree is expanded or hidden. The state of those elements is sufficient to reconstruct the visibility state of the tree. Starting from the root, which is always visible:

* If an element is in “hide” mode, hide all of its descendants recursively.
* If an element is in “expanded” mode, make its direct children visible, then repeat this logic on each of them.

To sanely implement this logic, you need a way to determine which elements are children of others. I’ve found a `Map` where the key is some ID and the values are an array of child elements easiest, but you could also store the data in the DOM using `dataset` ([MDN](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dataset)) and `id`  and do lookups with `getElementById` easily enough.

When changing the state of an expandable element, first update the UI element, then run the algorithm above over the subtree starting at that element.

## Initial Visibility
Storing page state in the URL allows user sharing, bookmarking, and decreases frustration on page reloads. If there’s a possibility for a user to select an item in your expandable tree (e.g. to see details elsewhere in the UI), you should probably store that state in the URL (`History.pushState` ([MDN](https://developer.mozilla.org/en-US/docs/Web/API/History/pushState)) is your friend here). 

If your subtrees are collapsed by default on page load (e.g. because you have a huge tree), you now have a problem: your page can load with an item selected that isn’t visible, confusing the user.

The solution to this is easiest to think about walking _up_ the tree, instead of down: starting at the tree parent of the selected item, mark the item expanded, then repeat for its parent until you reach the root. In reality, you can do this with return values during your initial tree rendering phase, without having to store parent information.

<!--# include file="include/bottom.html" -->
