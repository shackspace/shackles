Controller = require 'controllers/base/controller'
RegistrationView = require 'views/registration_view'
{UnassignedIds} = require 'models/unassigned'
{User} = require 'models/user'

module.exports = class RegistrationController extends Controller
	historyURL: 'registration'

	index: ->
		unassignedIds = new UnassignedIds()
		unassignedIds.fetch
			data:
				query:
					date:
						$gte: moment().subtract(1, 'hour').toJSON()
				sort:
					date: -1
		@view = new RegistrationView
			collection: unassignedIds

		@subscribeEvent 'registration:register', (user) =>
			$.ajax 
				url: '/api/user'
				type: 'POST'
				data: JSON.stringify
					username: user.username
					rfid: user.rfid
				contentType: 'application/json'
				success: (model, response, options) =>
					console.log response