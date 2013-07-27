request = require 'request'
host = 'http://localhost:9000'

request
	url: host + '/api/user'
	method: 'POST'
	json:
		_id: 'rash'
		rfids: ['004D9AF24560']