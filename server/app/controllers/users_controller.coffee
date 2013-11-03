Controller = require 'controllers/base/controller'
{UsersView} = require 'views/user_views'
{User, Users} = require 'models/user'

module.exports = class UserController extends Controller
	historyURL: 'users'

	index: ->
		users = new Users()
		users.fetch
			data:
				sort:
					status: 1
		@view = new UsersView
			collection: users

		