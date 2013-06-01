{SerialPort} = require 'serialport'
displaySize = 39
text = 'SHACKles SHACKles SHACKles SHACKles'
run = 1
runText = ''
display = new SerialPort '/dev/ttyO2'

printStuff = ->
    if run <= text.length
        display.write '\r\n' + text[-run..]
    else if run <= displaySize 
        display.write Array(text.length+1).join('\b') + ' ' + text
    else if run isnt displaySize+text.length
        display.write Array(text.length+displaySize-run+2).join('\b')
        display.write ' ' + text[..text.length+displaySize-run-1]
    else
        display.write '\r\n'
        
    run %= displaySize + text.length    
    run++


display.open ->
    display.write '\r\n'
    setInterval printStuff, 50
