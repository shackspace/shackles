User = global.mongoose.model 'User'

Crud = require './Crud'

module.exports = class UserRouter extends Crud
	model: User
	prefix: 'user'


	constructor: (app) ->
		super app

		app.get "/api/id/:id", @getId
		app.get "/api/user/:id/login", @login
		app.get "/api/user/:id/logout", @logout

	# resolve rfid to user
	getId: (req, res) =>
		@model.findOne {rfids: req.params.id}, {activity: {$slice: -1}}, (err, item) ->
			if item?
				res.json item
			else
				res.json 404, null

	login: (req, res) =>
		@model.update {_id: req.params.id}, {$push :{activity: {date: Date.now(), action: 'login'}}}, (err, numAffected) ->
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