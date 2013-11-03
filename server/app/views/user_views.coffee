View = require 'views/base/view'
CollectionView = require 'views/base/collection_view'
timeoutThreshold = moment.duration '12:00'

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

	getTemplateData: =>
		data = super()
		if data.status is 'logged in'
			data.timeLeft = moment(data.activity[0].date).add(timeoutThreshold).diff moment()
			data.timeLeftFraction = data.timeLeft/timeoutThreshold.asMilliseconds()
			data.humanTimeLeft = moment.duration(data.timeLeft).humanize()
		data

class UsersCollectionView extends CollectionView
	tagName: 'table'
	className: 'table table-bordered'
	itemView: UserItemView
	listSelector: 'tbody'
	template: require '/views/templates/users_collection'
