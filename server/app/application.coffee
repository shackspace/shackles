Router = Chaplin.Router
mediator = require 'mediator'
# AuthenticationController = require 'controllers/authentication_controller'
HeaderController = require 'controllers/header_controller'
FooterController = require 'controllers/footer_controller'
# Layout = require 'views/layout'

require 'lib/iosync'

# The application object
module.exports = class Application extends Chaplin.Application
	# Set your application name here so the document title is set to
	# “Controller title – Site title” (see Layout#adjustTitle)
	title: 'shackles'
	serverUrl: location.protocol + "//" + location.host
	initialize: (options) ->

		# Initialize core components
		@initDispatcher()
		@initLayout()
		@initComposer()
		@initMediator()
		@initSocket =>
			@initRouter options.routes
			@initControllers()
			@start()

	# 	@router = new Router()

	# 	mediator.subscribe '!auth:success', =>
	# 		@initControllers()
	# 		# register routes late
	# 		routes @router.match
	# 		@router.startHistory()
	# 		#mediator.publish '!router:route', ''

		
	# 	# 	auth = new AuthenticationController()

	# 	# Freeze the application instance to prevent further changes
	# 	Object.freeze? this

	# Override standard layout initializer
	# ------------------------------------
	# initLayout: ->
	# 	# Use an application-specific Layout class. Currently this adds
	# 	# no features to the standard Chaplin Layout, it’s an empty placeholder.
	# 	@layout = new Layout {@title}

	# Instantiate common controllers
	# ------------------------------
	initControllers: ->
		new HeaderController()
		new FooterController()

	# Create additional mediator properties
	# -------------------------------------
	# initMediator: ->
	# 	# Create a user property
	# 	Chaplin.mediator.user = null
	# 	# Add additional application-specific properties and methods
	# 	# Seal the mediator
	# 	Chaplin.mediator.seal()

	initSocket: (cb) =>
		socket = io.connect @serverUrl
		$emit = socket.$emit
		socket.$emit = () ->
			args = Array.prototype.slice.call arguments
			mediator.publish "!io:#{args[0]}", args[1..]
			$emit.apply socket, arguments

		mediator.subscribe '!io:emit', ->
			args = Array.prototype.slice.call arguments
			socket.emit.apply socket, args

		socket.on 'connect', cb

		socket.on 'error', () ->
			console.log 'LOL'
