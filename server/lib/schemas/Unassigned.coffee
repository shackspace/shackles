# der
Schema = global.mongoose.Schema

schema = new Schema
	_id: String
	date:
		type: Date
		default: Date.now

module.exports = schema