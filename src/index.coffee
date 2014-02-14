(($) ->
	# Global data
	listeners = []
	animationCount = 0
	animationEvents = "animationstart mozanimationstart webkitAnimationStart oAnimationStart msanimationstart"
	processedGUIDs = []
	documentTagged = false

	# Tag an element as processed by everyInsert
	tag = (el) ->
		$(el).prop('everyInsertTagged', true)

	isTagged = (el) ->
		if $(el).prop('everyInsertTagged')?
			_isTagged = true
		else
			_isTagged = false

		return _isTagged

	# Private event for listening for new dom insertions
	onInsert = (options,callback) ->
		selector = options.selector
		success = options.success || Function.prototype
		handleObj = options.handleObj

		index = animationCount + 1

		animationCount++

		animationName = "_nodeInserted_#{index}"

		# Determine prefixes for CSS animations
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

		# Create the style tag for animations, if one doesn't exist yet
		handleObj.data.styleTag = styleTag = $('<style type="text/css" />')
		stylecontent = """
		@#{cssPrefix}keyframes #{animationName} {
			from: { outline: 0px solid transparent } to { outline: 1px solid transparent }
		}

		#{selector} {
			#{cssPrefix}animation-duration: 0.001s;
			#{cssPrefix}animation-name: #{animationName};
		}
		"""
		styleTag.html(stylecontent)
		$('head').append(styleTag)

		# Listen for animationstart event, and when it matches the same
		# animation name, call the callback
		onAnimation = (e) =>
			target = e.target

			# If element was already inserted before, don't fire
			return if isTagged(target)

			tag(target)

			eventAnimationName = e.originalEvent.animationName

			# See if there is a WebkitAnimationName, etc.. property
			if not eventAnimationName
				eventAnimationName = e.originalEvent["#{prefix.dom}AnimationName"]

			# Now check if animation is the one you are looking for
			if eventAnimationName == animationName
				success(e)

		handleObj.data.ns = ns = ".#{handleObj.guid}"
		namespacedAnimationEvents = animationEvents.replace(/[ ]/g,"#{ns} ").trim() + ns
		handleObj.data.namespacedAnimationEvents = namespacedAnimationEvents

		$(document).on(namespacedAnimationEvents, selector, onAnimation)

	$.event.special.everyinsert =
		add: (handleObj) ->
			# Only need to add event for each GUID once.. so if you do
			# $('input').on('everyinsert') it won't add all the bindings for
			# each input. it will just add each one.
			if handleObj.guid in processedGUIDs
				return
			processedGUIDs.push(handleObj.guid)

			selector = handleObj.selector

			handleObj.data = handleObj.data || {}

			# Set up success callback
			callback = (e) =>
				if not e
					e is null

				if e?.currentTarget?
					ctx = $(e.currentTarget)
				else if e instanceof $
					ctx = e
				else
					ctx = null

				handleObj.handler.call(ctx, e)

			# Execute on existing elements *if specified*
			if not handleObj?.data?.existing? or handleObj.data.existing is true
				$(this).find(selector).each ->
					callback($(this))

			if not documentTagged
				$(document).ready =>
					# Prevents animations getting fired on elements getting shown
					documentTagged = true

					$('body *').each -> tag(this)

			if selector
				# Listen for new inserts
				onInsert({
					el: $(this),
					selector: selector,
					handleObj: handleObj,
					success: callback
				})

		remove: (handleObj) ->
			data = handleObj['data']
			# Remove style tag
			$('head style').filter(->
				styleTag = handleObj['data']['styleTag'][0]
				if(this is styleTag)
					return true
				else
					return false
			).remove()

			# Remove event listeners
			$(document).off(data.namespacedAnimationEvents)
)(jQuery)