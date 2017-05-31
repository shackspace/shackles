# Controller for the User model, communicates mediator events

mediator = require '../mediator'
mongoose = require 'mongoose'

User = mongoose.model 'User'
Unassigned = mongoose.model 'Unassigned'
crypto = require 'crypto'

hash = (text) -> crypto.createHash('md5').update(text).digest 'hex'

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

module.exports = class UserController

	constructor: ->
		mediator.on '!user:list', @list
		mediator.on '!user:get', @item
		mediator.on '!user:online', @online

		mediator.on '!user:register', @register
		mediator.on '!user:getByRfid', @getByRfid
		mediator.on '!user:login', @login
		mediator.on '!user:logout', @logout
		mediator.on 'snmp:device-joined', @snmpLogin
		mediator.on 'snmp:device-left', @snmpLogout

	list: (query, projection, options, cb) =>
		args = Array.prototype.slice.call arguments
		cb = args.pop()
		query = args[0] or {}
		projection = args[1] or {}
		options = args[2] or {}
		User.find query, projection, options, (err, users) ->
			console.log err if err?
			cb err, users

	item: (id, cb) =>
		User.findById id, (err, user) ->
			console.log err if err?
			cb err, user
	
	online: (cb) =>
		@list {status: 'logged in'}, (err, users) =>
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
			cb null,
				message: message
				users: online

	register: (register, cb) =>
		# register should be username, rfid

		# check rfid for uniqueness in one upsert query
		rfidHash = hash register.rfid
		User.update
			_id: register.username
			rfids: {$ne: rfidHash}
		,
			$push: {rfids: rfidHash}
			$setOnInsert: {status: 'logged out', activity: []}
		,
			upsert: true
		, (err, numberAffected) =>
			if err? and err.code is 11000 # duplicate index
				cb 'conflict'
			else if err?
				console.log err 
				cb err
			else
				Unassigned.remove {_id: register.rfid}, (err) ->
					console.log err if err?
				cb null

	# resolve rfid to user
	getByRfid: (rfid, cb) =>
		#hack to block old mac monitor
		if rfid.indexOf(':') is 2
			cb 404
			return
		rfidHash = hash rfid
		User.findOne {rfids: rfidHash}, {activity: {$slice: -1}}, (err, user) ->
			# TODO err
			if user?
				cb null, user
			else
				Unassigned.update
					_id: rfid
				,
					date: Date.now()
				,
					upsert: true
				, (err) ->
					console.log err if err?
				cb 404

	login: (id, cb) =>
		User.update {_id: id}, {$push :{activity: {date: Date.now(), action: 'login'}}, status: 'logged in'}, (err, numAffected) ->
			if err?
				console.log err
				cb? err
			else if numAffected is 1
				mediator.emit 'user:loggedIn', id
				cb?()
			else
				cb? 404

	logout: (id, cb) =>
		User.update {_id: id}, {$push :{activity: {date: Date.now(), action: 'logout'}}, status: 'logged out'}, (err, numAffected) ->
			if err?
				console.log err
				cb? err
			else if numAffected is 1
				mediator.emit 'user:loggedOut', id
				cb?()
			else
				cb? 404

	snmpLogin: (mac) =>
		# don't use getByRfid, we dont want to list macs in the Unassigned list
		macHash = hash mac
		User.findOne {rfids: macHash}, {activity: 0}, (err, user) =>
			return unless user?
			@login user._id

	snmpLogout: (mac) =>
		# don't use getByRfid, we dont want to list macs in the Unassigned list
		macHash = hash mac
		User.findOne {rfids: macHash}, {activity: 0}, (err, user) =>
			return unless user?
			@logout user._id
