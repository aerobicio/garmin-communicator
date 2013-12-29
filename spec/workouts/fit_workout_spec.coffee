{Communicator} = require('../../src/communicator')
{FitWorkout} = require('../../src/workouts/fit_workout')

describe 'FitWorkout', ->
  beforeEach ->
    @device = sinon.stub(number: 1)
    @id = 1
    @type = 'typeProp'
    @date = new Date
    @path = 'pathProp'
    @class = new FitWorkout(@device, @id, @type, @date, @path)
    @class.communicator.invoke = sinon.stub()

  afterEach ->
    Communicator.destroy()
    @class = null

  describe "#getData", ->
    it 'returns a promise of data', ->
      promise = @class.getData()
      expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

  describe "#_getBinaryFile", ->
    it "invokes the GetBinaryFile method on the plugin", ->
      @class.communicator.invoke.withArgs("GetBinaryFile", 1, 'pathProp', false).returns('binary as')
      expect(@class._getBinaryFile()).to.be.equal 'binary as'
