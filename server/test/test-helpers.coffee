# This file will be automatically required when using `brunch test` command.
chai = require 'chai'
sinonChai = require 'sinon-chai'
chai.use sinonChai

module.exports =
  should: chai.should()
  sinon: require 'sinon'
