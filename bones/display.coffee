{SerialPort} = require 'serialport'
displaySize = 40
text = 'mimimimimimimimimimi'
run = 1
runText = ''
display = new SerialPort '/dev/ttyO2'

printStuff = ->

    if run <= text.length
        display.write '\r' + text[-run..]
    else if run <= displaySize 
        display.write Array(text.length+1).join('\b') + ' ' + text
    else if run isnt displaySize+text.length
        display.write Array(text.length+displaySize-run+2).join('\b')
        display.write ' ' + text[..text.length+displaySize-run-1]
    else
        display.write '\r\n'
        
    run %= displaySize + text.length    
    run++

printLoop = ->
    trailingSpaces = run - text.length
    
    if trailingSpaces < 0
        trailingSpaces = 0

    runText = 

    


display.open ->
    display.write '\r\n'
#    setInterval printStuff,50
    display.write Array(41).join('a')
    display.write Array(41).join('b')
