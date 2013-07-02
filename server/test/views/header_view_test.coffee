mediator = require 'mediator'
Header = require 'models/header'
HeaderView = require 'views/header_view'

class HeaderViewTest extends HeaderView
  renderTimes: 0

  render: ->
    super
    @renderTimes += 1

describe 'HeaderView', ->
  beforeEach ->
    @model = new Header()
    @view = new HeaderViewTest({@model})

  afterEach ->
    @view.dispose()
    @model.dispose()

  it 'should display 4 links', ->
    @view.$el.find('.nav a').should.have.length 4

  it 'should re-render on login event', ->
    @view.renderTimes.should.equal 1
    mediator.publish 'loginStatus'
    @view.renderTimes.should.equal 2
