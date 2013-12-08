# Controller for the User model, communicates mediator events

mediator = require '../mediator'
mongoose = require 'mongoose'
credential = require 'credential'

User = mongoose.model 'User'
Unassigned = mongoose.model 'Unassigned'
crypto = require 'crypto'

hash = (text) -> crypto.createHash('md5').update(text).digest 'hex'

module.exports = class UserController

	constructor: ->
		mediator.on '!user:list', @list
		mediator.on '!user:get', @item

		mediator.on '!user:register', @register
		mediator.on '!user:getByRfid', @getByRfid
		mediator.on '!user:login', @login
		mediator.on '!user:logout', @logout

	# authenticate user, returns the user on success
	authenticate: (username, password, cb) =>
		User.findById username, (err, user) =>
			credential.verify user.password, password, (err, isValid) =>
				cb err, (user if isValid)

	requestLatePasswordToken: (username, cb) =>
		User.update {_id: username}, {latePasswordToken: DERP}

	setLatePassword: (username, password, token, cb) =>
		User.find {_id: username, latePasswordToken: token}, (err, user) =>
			return cb null unless user?
			credential.hash password, (err, hash) =>
				user.password = hash
				user.save (err) =>
					cb err

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
		rfidHash = hash rfid
		User.findOneAndUpdate
			rfids: rfidHash
		,
			$unset:
				latePasswordToken: ''
		,
			select:
				activity: 
					$slice: -1
				password: 0
			new: false
		, (err, user) =>
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
				cb err
			else if numAffected is 1
				mediator.emit 'user:loggedIn', id
				cb()
			else
				cb 404

	logout: (id, cb) =>
		User.update {_id: id}, {$push :{activity: {date: Date.now(), action: 'logout'}}, status: 'logged out'}, (err, numAffected) ->
			if err?
				console.log err
				cb err
			else if numAffected is 1
				mediator.emit 'user:loggedOut', id
				cb()
			else
				cb 404