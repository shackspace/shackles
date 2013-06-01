
BoneDisplay = require './BoneDisplay'

boneDisplay = new BoneDisplay '/dev/ttyO2'

boneDisplay.on 'ready', ->
    boneDisplay.displayText 'stuff'
