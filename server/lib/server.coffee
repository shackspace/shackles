log4js = require 'log4js'
logger = log4js.getLogger 'my-project'
logger.setLevel 'INFO'

express = require 'express'
path = require 'path'

app = module.exports = express()

# Load db stuff

mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/my-project'
global.mongoose = mongoose

Project = mongoose.model 'Model', require('./schemas/Model'), 'models'

# Server config

app.configure ->
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use express.cookieParser 'ponies'
	app.use express.session()
	# app.use log4js.connectLogger log4js.getLogger 'my-project-access'
	app.use express.static __dirname + '/../public'
	app.use app.router

app.configure 'development', ->
	app.use express.errorHandler {dumpExceptions: true, showStack:true }

app.configure 'production', ->
	app.use express.errorHandler()

# admin routers
ModelRouter = require './routers/Model'


# cheap user list
users =
	root:
		username: 'root'
		password: 'password'

app.post '/authenticate', (req, res) ->
	if req.body.user?
		user = users[req.body.user.username]
		if user? and user.password = req.body.user.password
			return res.json user
		res.send 404
	else
		if req.session?.user?
			return req.session.user
		res.send 401

app.get '*', (req, res) ->
	res.sendfile path.normalize __dirname + '/../public/index.html'

server = app.listen 9000, ->
	logger.info "Express server listening on port %d in %s mode", 9000, app.settings.env

io = require('socket.io').listen server

# io.sockets.on 'message', (msg) ->
# 	console.log 'message', msg

io.sockets.on 'connection', (socket) ->
	socket.on 'projects/list', (msg) ->
		console.log 'on', msg
	socket.on 'message', (msg) ->
		console.log 'msgsock', msg
# 	new IoRouter socket