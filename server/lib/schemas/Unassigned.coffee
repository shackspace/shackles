mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
	_id: String
	date:
		type: Date
		default: Date.now

module.exports = schema