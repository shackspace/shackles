mediator = require '../mediator'
mongoose = require 'mongoose'
moment = require 'moment'

log4js = require 'log4js'
log = log4js.getLogger 'timeout'
log.setLevel if process.isTest then 'FATAL' else 'INFO'

User = mongoose.model 'User'

timeoutThreshold = moment.duration '12:00'

module.exports = class TimeoutController

	constructor: ->
		mediator.emit '!user:list', {}, {activity: {$slice: -1}}, (err, users) ->
			for user in users
				continue if user.activity.length < 1
				continue if user.activity[0].action isnt 'login'
				if moment().diff(moment(user.activity[0].date).add(timeoutThreshold)) <= 0
					mediator.emit '!user:logout', user._id, ->
						log.info 'automatically logged out ' + user._id


		mediator.on 'user:loggedIn', (id) ->
			setTimeout ->
				mediator.emit '!user:logout', id, ->
					log.info 'automatically logged out ' + id
			, timeoutThreshold.asMilliseconds()