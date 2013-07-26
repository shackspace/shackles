async = require 'async'
request = request 'request'
serialport = require 'serialport'
SerialPort = serialport.SerialPort

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
		request
			url: serverUrl + '/api/id/' + data
			method: 'GET'
			json: true
		, (error, response, body) ->
			if response.statusCode is 404
				display.write '\r\n' + 'No user found for' + data
			else if response.statusCode is 200
				action = 'login'
				if body.activity? and body.activity[0]? and body.activity[0].action is 'login'
					action = 'logout'
				request
					url: serverUrl + '/api/user' + body._id + '/' + verb
					method: 'GET'