log4js = require 'log4js'
log = log4js.getLogger 'ircbot'

# suppress verbose output when testing
log.setLevel if process.isTest then 'ERROR' else 'DEBUG'

mediator = require '../mediator'

irc = require 'irc'

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

module.exports = class Bot extends irc.Client
	constructor: (name, channels) ->
		super 'chat.freenode.net', name,
			channels: channels
			userName: 'shackles'

		@addListener 'error', (message) ->
			log.error message

		@addListener 'message', @message
	

	message: (from, to, message) =>
		if message is '.online'
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
				@say to, message