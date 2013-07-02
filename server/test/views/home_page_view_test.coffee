HomePageView = require 'views/home_page_view'

describe 'HomePageView', ->
  beforeEach ->
    @view = new HomePageView()

  afterEach ->
    @view.dispose()

  # it 'should auto-render', ->
    # @view.$el.find('img').should.have.length 1
