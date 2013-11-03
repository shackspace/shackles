module.exports = class Crud

	constructor: (app) ->
		app.get "/api/#{@prefix}", @list
		app.post "/api/#{@prefix}", @add
		app.get "/api/#{@prefix}/:id", @item
		app.put "/api/#{@prefix}/:id", @update
		app.delete "/api/#{@prefix}/:id", @delete

	list: (req, res) =>
		# parse shitty sort querystring, because 1 and -1 are strings now
		sort = {}
		for key, value of req.query.sort
			sort[key] = parseInt value
		@model.find req.query.query, req.query.projection, {sort: sort}, (err, items) ->
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
			if item?
				res.json item
			else
				res.json 404, null

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
