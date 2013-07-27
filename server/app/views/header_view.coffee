mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class HeaderView extends View
	template: require 'views/templates/header'
	id: 'header'
	className: 'navbar navbar-fixed-top'
	container: '#header-container'
	autoRender: true

	initialize: ->
		super
		@subscribeEvent 'loginStatus', @render
		@subscribeEvent 'startupController', @render
