async = require 'async'

serialport = require 'serialport'
SerialPort = serialport.SerialPort


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
		display.write '\r\n' + data
