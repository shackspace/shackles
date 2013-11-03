View = require 'views/base/view'
CollectionView = require 'views/base/collection_view'

module.exports.UsersView = class UsersView extends View
	container: '#page-container'
	autoRender: true
	template: require '/views/templates/users'
	className: 'row users'

	initialize: ->
		super
		@subview 'users', new UsersCollectionView
			collection: @collection

	render: ->
		super
		@subview('users').container = @$ '#users'
		@subview('users').render()

class UserItemView extends View
	template: require '/views/templates/user_item'
	tagName: 'tr'

class UsersCollectionView extends CollectionView
	tagName: 'table'
	className: 'table table-bordered'
	itemView: UserItemView
	listSelector: 'tbody'
	template: require '/views/templates/users_collection'
