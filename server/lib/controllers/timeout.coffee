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

		logout = (userId) ->
			mediator.emit '!user:logout', userId, ->
					log.info 'automatically logged out ' + userId


		mediator.emit '!user:list', {}, {activity: {$slice: -1}}, (err, users) ->
			for user in users
				continue if user.activity.length < 1
				continue if user.activity[0].action isnt 'login'
				diff = moment(user.activity[0].date).add(timeoutThreshold).diff moment()
				if diff <= 0
					logout user._id
				else
					setTimeout ->
						logout user._id
					, diff

		mediator.on 'user:loggedIn', (id) ->
			setTimeout ->
				logout id
			, timeoutThreshold.asMilliseconds()

