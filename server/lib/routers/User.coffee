User = global.mongoose.model 'User'
Unassigned = global.mongoose.model 'Unassigned'
crypto = require 'crypto'

hash = (text) -> crypto.createHash('md5').update(text).digest 'hex'

module.exports = class UserRouter
	model: User
	prefix: 'user'


	constructor: (app) ->
		app.get "/api/#{@prefix}", @list
		app.get "/api/#{@prefix}/:id", @item

		app.post "/api/user", @register
		app.get "/api/id/:id", @getId
		app.get "/api/user/:id/login", @login
		app.get "/api/user/:id/logout", @logout

	list: (req, res) =>
		@model.find req.query, (err, items) ->
			console.log err if err?
			res.json items

	item: (req, res) =>
		@model.findById req.params.id, (err, item) ->
			console.log err if err?
			if item?
				res.json item
			else
				res.json 404, null

	register: (req, res) =>
		# body should be username, rfid

		# check rfid for uniqueness in one upsert query
		register = req.body
		rfidHash = hash register.rfid
		User.update
			_id: register.username
			rfids: {$ne: rfidHash}
		,
			$push: {rfids: rfidHash}
		,
			upsert: true
		, (err, numberAffected) =>
			if err? and err.code is 11000 # duplicate index
				res.send 404 # better code?
			else if err?
				console.log err 
			else
				Unassigned.remove {_id: register.rfid}, (err) ->
					console.log err if err?
				res.send 200

	# resolve rfid to user
	getId: (req, res) =>
		rfidHash = hash req.params.id
		@model.findOne {rfids: rfidHash}, {activity: {$slice: -1}}, (err, item) ->
			if item?
				res.json item
			else
				Unassigned.update
					_id: req.params.id
				,
					date: Date.now()
				,
					upsert: true
				, (err) ->
					console.log err if err?
				res.json 404, null

	login: (req, res) =>
		@model.update {_id: req.params.id}, {$push :{activity: {date: Date.now(), action: 'login'}}}, (err, numAffected) ->
			console.log err if err?
			if numAffected is 1
				res.send 200
			else
				res.send 404



	logout: (req, res) =>
		@model.update {_id: req.params.id}, {$push :{activity: {date: Date.now(), action: 'logout'}}}, (err, numAffected) ->
			if numAffected is 1
				res.send 200
			else
				res.send 404