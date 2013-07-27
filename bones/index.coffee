async = require 'async'
request = require 'request'
serialport = require 'serialport'
SerialPort = serialport.SerialPort
util = require 'util'

serverUrl = 'http://10.42.15.69:9000'
rfidReader = new SerialPort '/dev/ttyUSB0',
	parser: serialport.parsers.readline '\n'

display = new SerialPort '/dev/ttyO2'


async.parallel [
	(cb) -> rfidReader.open cb
, 
	(cb) -> display.open cb
]
, (err) ->
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
				display.write '\r\n' +  '!!SERVER DOWN!!'
			else if response.statusCode is 404
				display.write '\r\n' + 'No user found for ' + id
			else if response.statusCode is 200
				action = 'login'
				if body.activity? and body.activity[0]? and body.activity[0].action is 'login'
					action = 'logout'
				request
					url: serverUrl + '/api/user/' + body._id + '/' + action
					method: 'GET'
				display.write '\r\n' + body._id + ' ' + action