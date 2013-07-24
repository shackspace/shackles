User = global.mongoose.model 'User'

Crud = require './Crud'

module.exports = class UserRouter extends Crud
	model: User
	prefix: 'user'


	constructor: (app) ->
		super app

		app.get "/api/id/:id", @getId
		app.get "/api/id/:id/login", @login
		app.get "/api/id/:id/logout", @logout

	# resolve rfid to user
	getId: (req, res) =>
		@model.findOne {rfids: req.params.id}, (err, item) ->
			if item?
				res.json item
			else
				res.json 404, null

	login: (req, res) =>
		@model.findOne {rfids: req.params.id}, (err, item) ->
			if item?
				item.activities.push
					action: 'login'
				res.json 200, item
			else
				res.json 404, null



	logout: (req, res) =>