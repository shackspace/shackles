{SerialPort} = require 'serialport'
_ = require 'underscore'
{EventEmitter} = require 'events'
{exec} = require 'child_process'

fortuneCall = 'fortune -asn 40'

module.exports = class BoneDisplay extends EventEmitter
	
	constructor: (@path, options) ->

		throw new Error 'Path to display undefined' if not @path? 
 
		options = {} if not options?       

		_.defaults options, 
			speed: 150
			displaySize: 39


		@displaySize = options.displaySize 
		@speed = options.speed
		throw new Error 'Speed is not numerical' if typeof @speed isnt 'number'

		@display = new SerialPort @path

		#EventEmitter magic
		@display.open =>
			@emit 'ready'


	# entry point for all printouts
	# options include:
	#   startingPoing: start or end
	#   direction: rtl, ltr or none
	#   finished: callback
	displayText: (text, options) =>
		throw new Error 'no text defined' if not text?

		options = {} if not options?
		_.defaults options,
			startingPoint: 'start'
			direction: 'none'
			finished: ''
			expire: 5000

		startingPoint = options.startingPoint
		direction = options.direction
		finished = options.finished
		expire = options.expire

		if startingPoint is 'end' and (direction is 'none' or direction is 'ltr')
			#hm, korrigieren oder einfach beenden?
			throw new Error "you're holding it wrong"

		if startingPoint is 'start' and direction is 'none' and text.length > 40
			direction = 'ltr'


		# kill \n and \r, these clear the display
		text = text.replace /[\r\n]/g, ''
		run = 1

		displayRunningLtr = =>
			if run <= text.length
				@display.write '\r' + text[-run..]
			else if run <= @displaySize 
				@display.write Array(text.length+1).join('\b') + ' ' + text
			else if run isnt @displaySize+text.length
				@display.write Array(text.length+@displaySize-run+2).join('\b')
				@display.write ' ' + text[..text.length+@displaySize-run-1]
			else
				@display.write '\r\n'
				
			run %= @displaySize + text.length    
			run++

		if @runningInterval?
			clearInterval @runningInterval

		if direction is 'none'
			console.log 'diplay Text: ', text
			@display.write '\r\n'
			@display.write text
			clearTimeout @expireTimer
			@expireTimer = setTimeout =>
				fortuneText = exec fortuneCall, (error, stdout, stderr) =>
					@displayText stdout,
						expire: 20000
			, expire
		else if direction is 'ltr'
			@display.write '\r\n'
			@runningInterval = setInterval displayRunningLtr, @speed