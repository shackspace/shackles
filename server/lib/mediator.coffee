# this module manages all the talky stuff between rest, ws, irc and db, and fires events
# it is a singelton, require will give you the global instance
{EventEmitter} = require 'events'


class Mediator extends EventEmitter
	constructor: ->
		#

module.exports = new Mediator()