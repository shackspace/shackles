View = require 'views/base/view'

module.exports = class Modal extends View
	# template: COPY templates/modal.jade
	className: 'modal fade'

	events:
		'click .save':   'save'
		'click .close,.btn-close': 'hide'
		'hidden':        'hidden'
		'keydown': 'keydown'
		# 'shown':         'shown'

	keydown: (event) =>
		return unless event.keyCode is 13
		event.preventDefault()
		@save()

	hide: (event) =>
		event.preventDefault() if event?
		@$el.modal 'hide'

	# save: (event) =>
	# 	event.preventDefault()
	# 	@trigger 'create', @getData()
	# 	@hide()

	render: () =>
		super
		@$el.modal('keyboard': true, 'backdrop': true)
		@delegateEvents()
		@$el.modal('show': true)
		@

	hidden: () ->
		@remove()
		false

	# shown: () ->
	#   App.Helpers.Forms.setFocus($(@el), true)
	#   false