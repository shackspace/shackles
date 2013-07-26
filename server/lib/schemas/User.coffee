# der
Schema = global.mongoose.Schema

Activity = new Schema
	date:
		type: Date
		default: Date.now
	action: String # 'login' or 'logout'

schema = new Schema
	_id: String
	rfids: [String]
	activity: [Activity]

module.exports = schema