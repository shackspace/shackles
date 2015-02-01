mediator = require '../mediator'

log4js = require 'log4js'
log = log4js.getLogger 'snmp'

module.exports = class SnmpRouter
	prefix: 'arp'

	constructor: (app) ->
		app.get "/api/my-mac", @snmp

	snmp: (req, res) =>
		ip = req.headers['x-forwarded-for'] or req.connection.remoteAddress
		mediator.emit '!snmp:get-mac-from-ip', ip, (err, mac) ->
			log.error err if err?
			if mac?
				res.json
					MAC: mac
			else
				res.json null
