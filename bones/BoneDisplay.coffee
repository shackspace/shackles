
{SerialPort} = require 'serialport'
_ = require 'underscore'
{EventEmitter} = require 'events'

module.exports = class BoneDisplay extends EventEmitter
    
    constructor: (@path, options) ->

        throw new Error 'Path to display undefined' if not @path? 
 
        options = {} if not options?       

        _.defaults options, 
            speed: 150
            displaySize: 40


        @displaySize = options.displaySize 
        @speed = options.speed
        throw new Error 'Speed is not numerical' if typeof @speed isnt 'number'

        @display = new SerialPort @path

        #EventEmitter magic
        @display.open =>
            @emit 'ready'


    # entry point for all printouts
    displayText: (text, options) =>

        throw new Error 'no text defined' if not text?

        options = {} if not options?
 
        _.defaults options,
            startingPoint: 'start'
            direction: 'rtl'

        run = 1

        printStuff = =>

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

       

        @display.write '\r\n'
        setInterval printStuff, @speed
         
