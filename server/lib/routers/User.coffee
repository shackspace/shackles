mediator = require '../mediator'

module.exports = class UserRouter
	prefix: 'user'

	constructor: (app) ->
		app.get "/api/#{@prefix}", @list
		app.get "/api/#{@prefix}/:id", @item

		app.post "/api/user", @register
		app.get "/api/id/:id", @getByRfid
		app.get "/api/rfid/:id", @getByRfid
		app.get "/api/user/:id/login", @login
		app.get "/api/user/:id/logout", @logout

	list: (req, res) =>
		mediator.emit '!user:list', req.query, (err, users) ->
			res.json users

	item: (req, res) =>
		mediator.emit '!user:get', req.params.id, (err, user) ->
			if user?
				res.json user
			else
				res.json 404, null

	register: (req, res) =>
		# body should be username, rfid

		# check rfid for uniqueness in one upsert query
		register =
			username: req.body.username
			rfid: req.body.rfid

		mediator.emit '!user:register', register, (err) ->
			if err? and err is 'conflict' # duplicate index
				res.send 404 # better code?
			else if err?
				res.send 500
			else
				res.send 200

	# resolve rfid to user
	getByRfid: (req, res) =>
		mediator.emit '!user:getByRfid', req.params.id, (err, user) ->
			if err? and err is 404
				res.json 404, null
			else if user?
				res.json user
			else
				res.send 500

	login: (req, res) =>
		mediator.emit '!user:login', req.params.id, (err) ->
			if err? and err is 404
				res.send 404
			else if err?
				res.send 500
			else
				res.send 200

	logout: (req, res) =>
		mediator.emit '!user:logout', req.params.id, (err) ->
			if err? and err is 404
				res.send 404
			else if err?
				res.send 500
			else
				res.send 200
