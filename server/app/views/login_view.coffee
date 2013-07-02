mediator = require 'mediator'
utils = require 'lib/utils'
PageView = require 'views/base/page_view'
template = 

module.exports = class LoginView extends PageView
  template: require 'views/templates/login'

  initialize: ->
    console.log 'login'

