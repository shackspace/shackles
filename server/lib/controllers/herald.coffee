mediator = require '../mediator'
HeraldClient = require 'shack-herald-client'

log4js = require 'log4js'
log = log4js.getLogger 'herald-client'
log.setLevel if process.isTest then 'FATAL' else 'INFO'

config = require '../../server_config'

module.exports = class HeraldClientController

	constructor: ->

		@heraldClient = new HeraldClient config

		@heraldClient.on 'error', (err) =>
			log.error err

		@heraldClient.on 'connected', =>
			log.info 'connected to herald'

		mediator.on 'user:loggedIn', (id) =>
			@heraldClient.publish
				content: "#{id} logged in"
				from: 'shackles'
				data:
					action: 'login'
					id: id
