mediator = require 'mediator'
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
			mediator.publish '!io:emit', "!user:register",
				username: user.username
				rfid: user.rfid
			, (err) =>
				if err?
					if err is 'conflict'
						@view.showConflictError()
					else
						@view.showServerError()
				else
					@view.showSuccess()