Model = require 'models/base/model'

module.exports = class User extends Model
	idAttribute: '_id'
	urlRoot: '/api/user'
