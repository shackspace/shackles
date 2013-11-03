Model = require 'models/base/model'
Collection = require 'models/base/collection'


module.exports.User = class User extends Model
	idAttribute: '_id'
	urlRoot: 'user'

module.exports.Users = class Users extends Collection
	model: User
	url: 'user'
