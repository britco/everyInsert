(($) ->
	# Global data
	listeners = []
	animationCount = 0
	animationEvents = "animationstart mozanimationstart webkitAnimationStart oAnimationStart msanimationstart"
	processedGUIDs = []

	# Save selector selector
	# http://stackoverflow.com/a/501316
	# http://pygments.org/demo/132921/
	# TODO: Look into optimization
	$.fn._init = $.fn.init
	$.fn.init = (selector, context) ->
		_super = $.fn._init.apply(this, arguments)

		# Save the selector as a string
		window.setTimeout(=>
			if selector and typeof selector is "string"
				if _super instanceof $
					_super.data "selector", selector
		, 5)

		_super

	$.fn.init.prototype = $.fn._init.prototype

	# Private event for listening for new dom insertions
	onInsert = (options,callback) ->
		selector = options.selector

		index = animationCount + 1

		animationCount++

		animationName = "_nodeInserted_#{index}"

		# Create the style tag for animations, if one doesn't exist yet
		prefix = (->
		  styles = window.getComputedStyle(document.documentElement, "")
		  pre = (Array::slice.call(styles).join("").match(/-(moz|webkit|ms)-/) or (styles.OLink is "" and ["", "o"]))[1]
		  dom = ("WebKit|Moz|MS|O").match(new RegExp("(" + pre + ")", "i"))[1]
		  dom: dom
		  lowercase: pre
		  css: "-" + pre + "-"
		  js: pre[0].toUpperCase() + pre.substr(1)
		)()

		cssPrefix = prefix['css']
		style = """
			<style type="text/css">
				@#{cssPrefix}keyframes #{animationName} {
					from: { outline: 0px solid transparent } to { outline: 1px solid transparent }
				}

				#{selector} {
					#{cssPrefix}animation-duration: 0.001s;
					#{cssPrefix}animation-name: #{animationName};
				}
			</style>
		"""

		$('head').append(style)

		# Listen for animationstart event, and when it matches the same
		# animation name, call the callback
		$(document).on(animationEvents, (e) =>
			animationName = e.originalEvent.animationName

			console.log "#{prefix.dom}AnimationName"

			if not animationName
				animationName = e.originalEvent["#{prefix.dom}AnimationName"]
		)

	$.event.special.everyInsert =
		add: (handleObj) ->
			# Only need to add event for each GUID once.. so if you do
			# $('input').on('everyInsert') it won't add all the bindings for
			# each input. it will just add each one.
			if handleObj.guid in processedGUIDs
				return

			processedGUIDs.push(handleObj.guid)

			# Wait a little bit while selector is saved
			window.setTimeout(=>
				selector = $(this).data('selector')

				if selector
					# Listen for new inserts
					callback = =>

					onInsert({
						el: $(this),
						selector: selector,
						handleObj: handleObj,
						success: callback
					})
			, 10)

			preHandler = (ctx) ->

)(jQuery)