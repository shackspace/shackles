Model = require 'models/base/model'
Collection = require 'models/base/collection'


module.exports.UnassignedId = class UnassignedId extends Model

module.exports.UnassignedIds= class UnassignedIds extends Collection
	model: UnassignedId
	url: '/api/unassigned'