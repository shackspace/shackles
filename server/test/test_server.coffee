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

crypto = require 'crypto'

hash = (text) -> crypto.createHash('md5').update(text).digest 'hex'

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
				username: 'rash'
				rfid: 'BEEF'
		, (error, response, body) ->
			done error if error?
			response.statusCode.should.equal 200
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
			body.rfids.should.include.members [hash 'BEEF']
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
			body.rfids.should.include.members [hash 'BEEF']
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
			url: host + '/api/user/rash/login'
			method: 'GET'
		, (error, response, body) ->
			done error if error?
			response.statusCode.should.equal 200
			done()

	it 'should 404 on wrong login', (done) ->
		req = request
			url: host + '/api/user/krebs/login'
			method: 'GET'
		, (error, response, body) ->
			done error if error?
			response.statusCode.should.equal 404
			done()

	it 'should logout with rfid', (done) ->
		req1 = request
			url: host + '/api/user/rash/logout'
			method: 'GET'
		, (error, response, body) ->
			done error if error?
			response.statusCode.should.equal 200
			done()

	it 'should 404 on wrong logout', (done) ->
		req = request
			url: host + '/api/user/krebs/logout'
			method: 'GET'
		, (error, response, body) ->
			done error if error?
			response.statusCode.should.equal 404
			done()