module.exports = class Crud

	constructor: (app) ->
		app.get "/admin/api/#{@prefix}", @list
		app.post "/admin/api/#{@prefix}", @add
		app.get "/admin/api/#{@prefix}/:id", @item
		app.put "/admin/api/#{@prefix}/:id", @update
		app.delete "/admin/api/#{@prefix}/:id", @delete


	list: (req, res) =>
		@model.find req.query, (err, items) ->
			console.log err if err?
			res.json items

	add: (req, res) =>
		item = new @model req.body
		item.save (err) ->
			console.log err if err?
			res.send item.toObject()

	item: (req, res) =>
		@model.findById req.params.id, (err, item) ->
			console.log err if err?
			res.json item

	delete: (req, res) =>
		@model.remove {_id: req.params.id}, (err) ->
			console.log err if err?
			res.send()
	
	update: (req, res) =>
		item = req.body
		id = item._id
		delete item._id
		@model.update {_id: id}, item, (err) ->
			console.log err if err?
			res.send()
