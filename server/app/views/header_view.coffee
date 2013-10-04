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

	initialize: ->
		super
		@subscribeEvent 'loginStatus', @render
		@subscribeEvent 'startupController', @render
