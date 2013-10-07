mongoose = require 'mongoose'
Schema = mongoose.Schema

Activity = new Schema
	date:
		type: Date
		default: Date.now
	action: String # 'login' or 'logout'

schema = new Schema
	_id: String
	rfids:
		type: [String]
		index:
			unique: true
	activity: [Activity]
	status:
		type: String # 'logged out', 'logged in'
		default: 'logged out'

module.exports = schema