# Migration script
redis = require 'redis'
async = require 'async'


mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/shackles'
global.mongoose = mongoose

User = mongoose.model 'User', require('./lib/schemas/User'), 'users'

# login stuff
client = redis.createClient 6379, 'glados.shack'

client.keys 'users.list.*', (err, keys) ->
	# don't know what keys is exactly, assume string
	getHashRegex = /users.list.(.*).name/
	for key in keys
		match = key.match(getHashRegex)
		if match?
			id = match[1]
			do (id) ->
				async.parallel [
					(cb) ->	client.get "users.list.#{id}.name", (err, username) -> cb err, username
				, 
					(cb) -> client.lrange "users.list.#{id}.history", 0, -1, (err, history) -> cb err, history
				]
				,
					(err, results) ->
						username = results[0]
						history = []
						for item in results[1]
							[date, action] = item.split ' '
							history.push
								date: Date date
								action: action

						user = new User
							_id: username
							rfids: [id]
							activity: history

						user.save (err) ->
							console.log user, err

						
