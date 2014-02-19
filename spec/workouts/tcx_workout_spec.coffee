{TcxWorkout} = require('../../src/workouts/tcx_workout')
{Accessor} = require('../../src/device/accessor')
{Communicator} = require('../../src/communicator')

describe 'TcxWorkout', ->
  beforeEach ->
    @accessorCheckFinishedStub = sinon.stub(Accessor.prototype, '_startCheckFinished').returns(true)
    @device = sinon.stub(number: 1)
    @id = 1
    @date = new Date
    @class = new TcxWorkout(@device, @id, @date)
    @communicatorInvokeStub = sinon.stub(@class.detailReader.communicator, 'invoke')

  afterEach ->
    Communicator.destroy()
    @class = null
    @accessorCheckFinishedStub.restore()
    @communicatorInvokeStub.restore()

  describe '#getData', ->
    it 'returns a promise of data', ->
      promise = @class.getData()
      expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

    it 'calls the Reader with the id of the workout to read', ->
      detailReader = perform: -> return
      detailReaderPerformStub = sinon.stub(detailReader, 'perform')
      @class.detailReader = detailReader
      @class.getData()
      expect(@class.detailReader.perform.calledWith(1)).to.be.true
