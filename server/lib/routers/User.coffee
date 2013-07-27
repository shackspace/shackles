User = global.mongoose.model 'User'
Unassigned = global.mongoose.model 'Unassigned'

Crud = require './Crud'

module.exports = class UserRouter extends Crud
	model: User
	prefix: 'user'


	constructor: (app) ->

		app.get "/api/#{@prefix}", @list
		app.get "/api/#{@prefix}/:id", @item

		app.post "/api/user", @register
		app.get "/api/id/:id", @getId
		app.get "/api/user/:id/login", @login
		app.get "/api/user/:id/logout", @logout

	register: (req, res) =>
		# body should be username, rfid

		# check rfid for uniqueness in one upsert query
		register = req.body
		User.update
			_id: register.username
			rfids: {$ne: register.rfid}
		,
			$push: {rfids: register.rfid}
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
		@model.findOne {rfids: req.params.id}, {activity: {$slice: -1}}, (err, item) ->
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
			console.log err
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