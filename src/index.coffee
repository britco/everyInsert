(($) ->
	# Global data
	listeners = []
	animationCount = 0
	animationEvents = "animationstart mozanimationstart webkitAnimationStart oAnimationStart msanimationstart"
	processedGUIDs = []
	documentTagged = false

	# Private event for listening for new dom insertions
	onInsert = (options,callback) ->
		selector = options.selector
		success = options.success || Function.prototype

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

		console.log 'adding listener'

		# Listen for animationstart event, and when it matches the same
		# animation name, call the callback
		$(document).on(animationEvents, selector, (e) =>
			target = e.target

			# If element was already inserted before, don't fire
			return if $(target).prop('everyInsertTagged')?

			$(target).prop('everyInsertTagged', true)

			eventAnimationName = e.originalEvent.animationName

			# See if there is a WebkitAnimationName, etc.. property
			if not eventAnimationName
				eventAnimationName = e.originalEvent["#{prefix.dom}AnimationName"]

			# Now check if animation is the one you are looking for
			if eventAnimationName == animationName
				success(e)
		)

	$.event.special.everyInsert =
		add: (handleObj) ->
			selector = handleObj.selector

			# Only need to add event for each GUID once.. so if you do
			# $('input').on('everyInsert') it won't add all the bindings for
			# each input. it will just add each one.
			if handleObj.guid in processedGUIDs
				return

			processedGUIDs.push(handleObj.guid)

			if not documentTagged
				$(document).ready =>
					# Prevents animations getting fired on elements getting shown
					documentTagged = true

					$('body *').each ->
						$(this).prop('everyInsertTagged', true)

			if selector
				# Listen for new inserts
				callback = (e) =>
					ctx = $(e.currentTarget)
					handleObj.handler.call(ctx, e)

				onInsert({
					el: $(this),
					selector: selector,
					handleObj: handleObj,
					success: callback
				})
)(jQuery)