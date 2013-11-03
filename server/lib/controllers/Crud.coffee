# Abstract Crud Controller
# extend and supply @model and @prefix

mediator = require '../mediator'

module.exports = class CrudController
	constructor: ->
		mediator.on "!#{@prefix}:list", @list
		#mediator.on "!#{@prefix}:create", @add
		mediator.on "!#{@prefix}:read", @item
		#mediator.on "!#{@prefix}:delete", @delete
		#mediator.on "!#{@prefix}:update", @update

	list: (query, projection, options, cb) =>
		args = Array.prototype.slice.call arguments
		cb = args.pop()
		query = args[0] or {}
		projection = args[1] or {}
		options = args[2] or {}
		@model.find query, projection, options, (err, users) ->
			console.log err if err?
			cb err, users

	item: (id, cb) =>
		@model.findById id, (err, user) ->
			console.log err if err?
			cb err, user