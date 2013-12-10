log4js = require 'log4js'
log = log4js.getLogger 'redis-pubsub'
redis = require 'redis'
mediator = require '../mediator'
config = require '../../server_config'

onlineVerbs = [
	'procrastinating'
	'sitting'
	'working'
	'hacking'
	'sleeping'
	'dancing'
	'building weapons of mass destruction'
	'rocking'
	'plotting your demise'
	'preparing for the zombie apocalypse'
	'planning world domination'
]

offlineMesgs = [
	'No one is home.'
	'The shack is deserted.'
	'No one in the shack wants to be surveilled.'
	'There is nothing to see here, carry on.'
	'The kitchen is the only living thing in the shack.'
]

module.exports = class RedisPubSub

	constructor: ->
		@sub = redis.createClient config.redis.port, config.redis.host
		@pub = redis.createClient config.redis.port, config.redis.host

		onError = (err) ->
			if err.message.indexOf 'ECONNREFUSED' > 0
				log.warn "can't call glados"
			else
				log.err err.message

		@sub.on 'error', onError
		@pub.on 'error', onError

		@sub.on 'subscribe', (channel, count) ->
			log.info 'subscribe', channel, count

		@sub.on 'message', (channel, message) =>
			if channel is 'bot' and message is '.online'
				mediator.emit '!user:list', {status: 'logged in'}, (err, users) =>
					log.debug users
					online = []
					for user in users
						online.push user._id
					
					if online.length is 0
						message = offlineMesgs[Math.floor(Math.random()*offlineMesgs.length)]
					else
						if online.length is 1
							message = online[0] + ' is'
						else
							message = "#{online[..-2].join(', ')} and #{online[-1..]} are"
						message +=  " currently #{onlineVerbs[Math.floor(Math.random()*onlineVerbs.length)]} in the shack."
					@pub.publish '!bot', message

		@sub.subscribe "bot"
