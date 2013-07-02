Model = global.mongoose.model 'Model'
Crud = require './Crud'

module.exports = class ModelRouter extends Crud
	model: Model
	prefix: 'model'
