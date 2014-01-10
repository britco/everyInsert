everyInsert
===========

Custom event for jQuery that gets called whenever an element with the selector you specify is inserted into the DOM. An alternative to DOMNodeInserted since that event is now deprecated.


## Download
[every-insert-0.1.0.js](https://raw2.github.com/britco/everyInsert/master/dist/every-insert-0.1.0.js)

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

By default, everyInsert will also run on existing elements. To turn this off,
turn existing: false. Like so:

````
$(document).on('everyInsert', 'div', { existing: false }, function() {});
````

## Inspiration
* http://davidwalsh.name/detect-node-insertion