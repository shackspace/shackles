Unassigned = global.mongoose.model 'Unassigned'

Crud = require './Crud'

module.exports = class UnassignedRouter extends Crud
	model: Unassigned
	prefix: 'unassigned'

	# constructor: (app) ->
	# 	app.get "/api/#{@prefix}", @list