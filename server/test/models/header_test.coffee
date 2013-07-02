Header = require 'models/header'

describe 'Header', ->
  beforeEach ->
    @model = new Header()

  afterEach ->
    @model.dispose()

  it 'should contain 4 items', ->
    @model.get('items').should.have.length 4
