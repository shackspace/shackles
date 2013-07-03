# der
Schema = global.mongoose.Schema

schema = new Schema
	username: String
	date: Date
	action: String # 'login' or 'logout'

module.exports = schema