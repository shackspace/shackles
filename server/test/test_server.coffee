process.isTest = true
should = require('chai').should()
request = require 'request'
fs = require 'fs'
path = require 'path'
async = require 'async'
log4js = require 'log4js'
log4js.setGlobalLogLevel 'FATAL'
mongoose = null

host = 'http://localhost:9000'
formtype = null
server = null

describe 'Server', ->

	after (done) ->
		mongoose.disconnect()
		for key,cache of require.cache
			if key.indexOf 'mongoose' isnt -1
				delete require.cache[key]
		done()

	before (done) ->
		mongoose = require 'mongoose'
		server = require '../'

		async.parallel [
			(cb) ->
				server.on 'ready', ->
					cb()
			, (cb) ->
				mongoose.connection.on 'open', ->
					mongoose.connection.db.dropDatabase (err) ->
						cb err
		] ,
			(err) ->
				done err

	it 'should register new user', (done) ->
		req = request
			url: host + '/api/user'
			method: 'POST'
			json:
				_id: 'rash'
				rfids: ['BEEF']
		, (error, response, body) ->
			done error if error?
			response.statusCode.should.equal 200
			body._id.should.equal 'rash'
			body.rfids.should.include.members ['BEEF']
			done()

	it 'should get user info by user id', (done) ->
		req = request
			url: host + '/api/user/rash'
			method: 'GET'
			json: true
		, (error, response, body) ->
			done error if error?
			response.statusCode.should.equal 200
			body._id.should.equal 'rash'
			body.rfids.should.include.members ['BEEF']
			done()

	it 'should 404 if user id does not exist', (done) ->
		req = request
			url: host + '/api/user/krebs'
			method: 'GET'
			json: true
		, (error, response, body) ->
			done error if error?
			response.statusCode.should.equal 404
			should.not.exist body
			done()

	it 'should get user info with rfid', (done) ->
		req = request
			url: host + '/api/id/BEEF'
			method: 'GET'
			json: true
		, (error, response, body) ->
			done error if error?
			response.statusCode.should.equal 200
			body._id.should.equal 'rash'
			body.rfids.should.include.members ['BEEF']
			done()

	it 'should 404 if rfid does not exist', (done) ->
		req = request
			url: host + '/api/id/B00B1E5'
			method: 'GET'
			json: true
		, (error, response, body) ->
			done error if error?
			response.statusCode.should.equal 404
			should.not.exist body
			done()

	it 'should login with rfid', (done) ->
		req = request
			url: host + '/api/id/BEEF/login'
			method: 'GET'
			json: true
		, (error, response, body) ->
			done error if error?
			response.statusCode.should.equal 200
			body._id.should.equal 'rash'
			body.rfids.should.include.members ['BEEF']
			body.activities.length.should.equal 1
			body.activities[0].action.should.equal 'login'
			done()

	it 'should 404 on login', (done) ->
		req = request
			url: host + '/api/id/B00B1E5/login'
			method: 'GET'
			json: true
		, (error, response, body) ->
			done error if error?
			response.statusCode.should.equal 404
			should.not.exist body
			done()