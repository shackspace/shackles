mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class HeaderView extends View
	template: require 'views/templates/header'
	id: 'header'
	className: 'navbar navbar-default navbar-fixed-top'
	attributes:
		role: 'navigation'
	container: '#header-container'
	autoRender: true

	events:
		'click #users': 'toUsers'
		'click .navbar-brand': 'toHome'

	initialize: ->
		super
		@subscribeEvent 'loginStatus', @render
		@subscribeEvent 'startupController', @render

	toHome: (event) =>
		event.preventDefault()
		Chaplin.helpers.redirectTo 'registration#index', trigger : true
		false

	toUsers: (event) =>
		event.preventDefault()
		Chaplin.helpers.redirectTo 'users#index'
		false
