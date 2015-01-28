
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
	log.info 'polling snmp'
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
				client.sadd logKey, varbind.value
			
			# get the diff
			client.sdiff logKey, preLogKey, (err, diff) ->
				log.debug 'different macs:', diff.length
				async.each diff, (mac, cb) ->
					humanMac = macAddress.toString(new Buffer(mac))
					# check if old or new mac
					client.sismember preLogKey, mac, (err, isMember) ->
						log.info err,isMember
						if isMember
							# obsolete mac
							log.info 'device left:', humanMac
						else
							log.info 'device joined:', humanMac
						cb()
				, (err) ->
					log.error err if err?
					setTimeout update, 10000


				# if ret is 1
				# 	log.info 'new device:', mac

update()
