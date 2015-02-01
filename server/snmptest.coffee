
async = require 'async'
snmp = require 'snmp-native'
macAddress = require 'mac-address'
redis = require 'redis'

log4js = require 'log4js'
log = log4js.getLogger 'snmp'

host = 'coreswitch.shack'
oid = '.1.3.6.1.2.1.3.1.1.2'

logKey = 'mac-log'
preLogKey = 'mac-log-pre'

session = new snmp.Session
	host: host
	community: 'shack'

client = redis.createClient()

update = ->
	log.debug 'polling snmp'
	session.getSubtree
		oid: oid
	, (err, varbinds) ->
		log.debug 'polled snmp'
		# move previous macs to another set
		tryRename = (cb) ->
			client.exists logKey, (err, ret) ->
				if ret is 1
					log.debug 'moving previous set'
					client.rename logKey, preLogKey, cb
				else
					cb null, false

		tryRename ->
			log.debug 'moved previous set'
			# add all current macs to a fresh set
			for varbind in varbinds
				mac = macAddress.toString(varbind.valueRaw)
				# log.debug mac
				client.sadd logKey, mac
			

			async.parallel [
				(cb) ->
					client.sdiff logKey, preLogKey, (err, diff) ->
						for mac in diff
							log.info 'device joined:', mac
						cb err
			,
				(cb) ->
					client.sdiff preLogKey, logKey, (err, diff) ->
						for mac in diff
							log.info 'device left:', mac
						cb err
			], (err) ->
				setTimeout update, 10000


				# if ret is 1
				# 	log.info 'new device:', mac

update()
