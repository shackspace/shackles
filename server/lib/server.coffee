log4js = require 'log4js'
log = log4js.getLogger 'shackles'
log.setLevel if process.isTest then 'FATAL' else 'INFO'

express = require 'express'
path = require 'path'

config = require '../server_config'

app = module.exports = express()

# Load db stuff

mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/shackles'

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

new (require('./rest/User')) app
new (require('./rest/Unassigned')) app

new (require('./irc/bot')) config.irc.channels

app.get '*', (req, res) ->
	res.sendfile path.normalize __dirname + '/../public/index.html'

server = app.listen config.port, ->
	log.info "Express server listening on port %d in %s mode", config.port, app.settings.env
	app.emit 'ready'