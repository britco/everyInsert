everyInsert
===========

Custom event for jQuery that gets called whenever an element with the selector you specify is inserted into the DOM.

Setup like so:

````
$(document).on('everyInsert', 'div.selector', function() {
	// code
})
```

Don't bind it directly to the element like `$('div.selector').on..`, because
the special event add function won't run if the element does not exist yet.

To turn off the listener

```
$(document).off('everyInsert', 'div.selector', callback)
````

## Inspiration
* http://davidwalsh.name/detect-node-insertion