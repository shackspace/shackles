async = require 'async'
request = require 'request'
serialport = require 'serialport'
SerialPort = serialport.SerialPort
util = require 'util'
BoneDisplay = require './BoneDisplay'

serverUrl = 'http://shackles.shack'
rfidReader = new SerialPort '/dev/ttyUSB0',
	parser: serialport.parsers.readline '\n'

boneDisplay = new BoneDisplay '/dev/ttyO2'

async.parallel [
	(cb) -> rfidReader.open cb
, 
	(cb) -> boneDisplay.on 'ready', cb
]
, (err) ->
	boneDisplay.displayText '      PORTHOS              0.1.0'
	rfidReader.on 'data', (data) ->
		id = data.replace /\W/g, ''
		request
			url: serverUrl + '/api/id/' + id
			method: 'GET'
			json: true
		, (error, response, body) ->
			if error?
				console.log serverUrl + '/api/id/' + id
				console.log error
				boneDisplay.displayText '!! SERVER DOWN !! SERVER DOWN !! SERVER DOWN !! SERVER DOWN !!',
					direction: 'ltr'
			else if response.statusCode is 404
				boneDisplay.displayText 'No user found for ' + id
			else if response.statusCode is 200
				action = 'login'
				if body.activity? and body.activity[0]? and body.activity[0].action is 'login'
					action = 'logout'
				request
					url: serverUrl + '/api/user/' + body._id + '/' + action
					method: 'GET'
				boneDisplay.displayText body._id + ' ' + action