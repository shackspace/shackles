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
	activities: [Activity]

module.exports = schema