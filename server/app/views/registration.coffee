View = require 'views/base/view'
CollectionView = require 'views/base/collection_view'

module.exports = class RegistrationView extends View
	container: '#page-container'
	autoRender: true
	template: require '/views/templates/registration'

	events:
		'submit form' : 'submit'

	initialize: ->
		super

		@subview 'unassigned', new UnnassignedCollectionView
			collection: @collection

		@subscribeEvent 'registration:selectedUnassigned', (rfid) ->
			@$('#rfid').val rfid

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