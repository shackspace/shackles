log4js = require 'log4js'
log = log4js.getLogger 'shackles'
log.setLevel if process.isTest then 'FATAL' else 'INFO'

express = require 'express'
path = require 'path'

config = require '../server_config'
mediator = require './mediator'

app = module.exports = express()

# Load db stuff

mongoose = require 'mongoose'
tries = 0
tryConnect = ->
	mongoose.connect 'mongodb://localhost/shackles', (err) ->
		if err?
			tries++
			log.error "can't connect to mongodb"
			setTimeout tryConnect, Math.min(500 * Math.log(tries), 5000)
tryConnect()
mongoose.connection.once 'open', ->
	 log.info 'got mongodb'
# mongoose.set('debug', true)
User = mongoose.model 'User', require('./schemas/User'), 'users'
Unassigned = mongoose.model 'Unassigned', require('./schemas/Unassigned'), 'unassigned'

# Server config

app.configure ->
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use express.cookieParser 'ponies'
	app.use express.session()
	app.use log4js.connectLogger log4js.getLogger 'access'
	app.use express.static __dirname + '/../public'
	app.use app.router

app.configure 'development', ->
	app.use express.errorHandler {dumpExceptions: true, showStack:true }

app.configure 'production', ->
	app.use express.errorHandler()

new (require('./controllers/User'))()
new (require('./controllers/Unassigned'))()
new (require('./controllers/timeout'))()
new (require('./controllers/herald'))()


new (require('./rest/User')) app
new (require('./rest/Unassigned')) app


# dont use the redis connector on unit tests
if not process.isTest
	new (require('./redis/redis'))()

app.get '*', (req, res) ->
	res.sendfile path.normalize __dirname + '/../public/index.html'

server = app.listen config.port, ->
	log.info "Express server listening on port %d in %s mode", config.port, app.settings.env
	app.emit 'ready'

io = require('socket.io').listen server
	# logger:
	# 	debug: ->
	# 		accessLogger.debug.apply accessLogger, arguments
	# 	info: ->
	# 		accessLogger.info.apply accessLogger, arguments
	# 	warn: ->
	# 		accessLogger.warn.apply accessLogger, arguments
	# 	error: ->
	# 		accessLogger.error.apply accessLogger, arguments

# start up submodules
io.sockets.on 'connection', (socket) =>
	$emit = socket.$emit
	socket.$emit = ->
		#args = Array.prototype.slice.call arguments
		mediator.emit.apply mediator, arguments
		$emit.apply socket, arguments

	# mediator.subscribe '!io:emit', () ->
	# 	args = Array.prototype.slice.call arguments
	# 	# console.log args[1..]
	# 	socket.emit.apply socket, args, args
 #  socket.emit('news', { hello: 'world' });
 #  socket.on('my other event', function (data) {
 #    console.log(data);
