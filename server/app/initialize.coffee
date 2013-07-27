Application = require 'application'
routes = require 'routes'

$ ->
  app = new Application
  	routes: routes
  # app.initialize()
