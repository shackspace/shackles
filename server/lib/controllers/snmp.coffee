mediator = require '../mediator'
config = require '../../server_config'

async = require 'async'
snmp = require 'snmp-native'
macAddress = require 'mac-address'
redis = require 'redis'

log4js = require 'log4js'
log = log4js.getLogger 'snmp'

logKey = 'mac-log'
preLogKey = 'mac-log-pre'


module.exports = class SNMPController
	constructor: ->

		@options = config.snmp
		@session = new snmp.Session
			host: @options.host
			community: @options.community

		@client = redis.createClient config.redis.port, config.redis.host

		mediator.on '!snmp:get-mac-from-ip', @getMacFromIp

		@update()

	update: =>
		log.debug 'polling snmp'
		@session.getSubtree
			oid: @options.oid
		, (err, varbinds) =>
			log.debug 'polled snmp'
			# move previous macs to another set
			tryRename = (cb) =>
				@client.exists logKey, (err, ret) =>
					if ret is 1
						log.debug 'moving previous set'
						@client.rename logKey, preLogKey, cb
					else
						cb null, false

			tryRename =>
				log.debug 'moved previous set'
				# add all current macs to a fresh set
				for varbind in varbinds
					mac = macAddress.toString varbind.valueRaw
					# log.debug mac
					@client.sadd logKey, mac

				async.parallel [
					(cb) =>
						@client.sdiff logKey, preLogKey, (err, diff) ->
							for mac in diff
								log.info 'device joined:', mac
								mediator.emit 'snmp:device-joined', mac
							cb err
				,
					(cb) =>
						@client.sdiff preLogKey, logKey, (err, diff) ->
							for mac in diff
								log.info 'device left:', mac
								mediator.emit 'snmp:device-left', mac
							cb err
				], (err) ->
					setTimeout @update, 10000

	getMacFromIp: (ip, cb) =>
		@session.getSubtree
			oid: @options.oid
		, (err, varbinds) =>
			return cb err if err?
			for varbind in varbinds
				varIp = varbind.oid[12..].join '.'
				if ip is varIp
					mac = macAddress.toString varbind.valueRaw
					log.info 'mac found for ip:', ip, mac
					cb null, mac
					return	
			log.info 'no mac found for ip:', ip
			cb null, null