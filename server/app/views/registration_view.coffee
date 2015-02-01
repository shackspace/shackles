View = require 'views/base/view'
CollectionView = require 'views/base/collection_view'

module.exports = class RegistrationView extends View
	container: '#page-container'
	autoRender: true
	template: require '/views/templates/registration'
	className: 'row'

	events:
		'submit form' : 'submit'
		'click #device-mac': 'useDeviceMac'

	initialize: ->
		super
		@subview 'unassigned', new UnnassignedCollectionView
			collection: @collection

		@subscribeEvent 'registration:selectedUnassigned', (rfid) ->
			@$('#rfid').val rfid

	showMac: (mac) =>
		$button = $ '#device-mac'
		if mac?
			$button.prop 'disabled', false
			$button.text "User your devices MAC (#{mac.MAC})"
			@deviceMac = mac
		else
			$button.text 'could not locate your device'
		

	render: ->
		super
		@subview('unassigned').container = @$ '#unassigned'
		@subview('unassigned').render()

	submit: (event) =>
		event.preventDefault()
		@publishEvent 'registration:register',
			username: @$('#username').val()
			rfid: @$('#rfid').val()
		return

	useDeviceMac: (event) =>
		event.preventDefault()
		@$('#rfid').val @deviceMac.MAC


	showSuccess: =>
		@$('#registration-form').hide()
		@$('#success').show()

	showServerError: =>
		@$('#registration-form').hide()
		@$('#error-server').show()

	showConflictError: =>
		@$('#registration-form').hide()
		@$('#error-conflict').show()

class UnassignedItemView extends View
	template: require '/views/templates/unassigned_item'
	tagName: 'li'

	events:
		'click': 'select'

	select: (event) =>
		event.preventDefault()
		@publishEvent 'registration:selectedUnassigned', @model.get '_id'
		return

class UnnassignedCollectionView extends CollectionView
	itemView: UnassignedItemView
	tagName: 'ul'