mediator = require 'mediator'

Backbone.sync = (method, model, options) ->

	if not model?.url?
		console.log 'no url!!'
		return
	
	url = if _.isFunction(model.url) then model.url() else model.url
	
	if method is 'read' and model instanceof Backbone.Collection
		method = 'list'
	if method is 'read' and model instanceof Backbone.Model
		url = model.urlRoot
		options.data = model.id
		
	if method is 'update'
		url = model.urlRoot
	
	url += ':' + method
	data = options.data or model.toJSON()
	cb = (err, data) ->
		if err?
			options.error err
		else
			options.success data
	if method is 'update'
		mediator.publish '!io:emit', url, model.id, data, cb
	else
		mediator.publish '!io:emit', url, data, cb
	return null
