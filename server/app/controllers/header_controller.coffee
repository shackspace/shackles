Controller = require 'controllers/base/controller'
mediator = require 'mediator'
HeaderView = require 'views/header_view'

module.exports = class HeaderController extends Controller
	initialize: ->
		super
		@view = new HeaderView()