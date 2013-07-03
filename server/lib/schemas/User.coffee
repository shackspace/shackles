# der
Schema = global.mongoose.Schema

schema = new Schema
	_id: String
	rfids: [String]

module.exports = schema