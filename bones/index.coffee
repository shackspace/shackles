exec = require('child_process').exec
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

greetingMessages = [
	'Welcome, $$'
	'Greetings, $$'
]

partingMessages = [
	'Goodbye, $$'
	'Farewell, $$'
]

tryId = (id) =>
	request
			url: serverUrl + '/api/id/' + id
			method: 'GET'
			json: true
		, (error, response, user) ->
			if error?
				console.log serverUrl + '/api/id/' + id
				console.log error
				boneDisplay.displayText '!! SERVER DOWN !! SERVER DOWN !! SERVER DOWN !! SERVER DOWN !!',
					direction: 'ltr'
			else if response.statusCode is 404
				boneDisplay.displayText 'No user found for   ' + id
			else if response.statusCode is 200
				if user.latePasswortToken?
					boneDisplay.displayText 'Here is the token to set your password: ', user.latePasswortToken
				else
					action = 'login'
					if user.activity? and user.activity[0]? and user.activity[0].action is 'login'
						action = 'logout'
					request
						url: serverUrl + '/api/user/' + user._id + '/' + action
						method: 'GET'

					if action is 'login'
						boneDisplay.displayText greetingMessages[Math.floor(Math.random()*greetingMessages.length)].replace '$$', user._id
					else if action is 'logout'
						boneDisplay.displayText partingMessages[Math.floor(Math.random()*partingMessages.length)].replace '$$', user._id

async.parallel [
	(cb) -> rfidReader.open cb
, 
	(cb) -> boneDisplay.on 'ready', cb
,
	(cb) -> exec 'systemctl stop bootmesg', cb
]
, (err) ->

	boneDisplay.displayText '      PORTHOS              0.1.0',
		expire: 3000
	rfidReader.on 'data', (data) ->
		id = data.replace /\W/g, ''
		tryId id


# poll mifare stick

nfcListRegex = /.*UID.*:(.*)/

pollMifare = =>
	exec 'nfc-list', (error, stdout, stderr) =>
		#TODO: handle errors

		match = stdout.match nfcListRegex
		if not match
			@mifareCurrentId = null
		else
			id = match[1].replace /\s/g, ''
			#prevent server spam with polling results
			if @mifareCurrentId isnt id
				@mifareCurrentId = id
				tryId id

		setTimeout pollMifare, 100

setTimeout pollMifare, 100

console.log 'BONE BOOTED'