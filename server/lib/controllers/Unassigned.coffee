mongoose = require 'mongoose'
Unassigned = mongoose.model 'Unassigned'

Crud = require './Crud'

module.exports = class UnassignedController extends Crud
	model: Unassigned
	prefix: 'unassigned'