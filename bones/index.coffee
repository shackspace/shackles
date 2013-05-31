serialport = require 'serialport'
SerialPort = serialport.SerialPort

serialPort = new SerialPort '/dev/ttyUSB0',
	parser: serialport.parsers.readline '\n'


serialPort.open ->
	serialPort.on 'data', (data) ->
		console.log data
