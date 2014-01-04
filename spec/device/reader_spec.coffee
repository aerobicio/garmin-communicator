{Reader}            = require('../../src/device/reader')
{Communicator}      = require('../../src/communicator')
{Plugin}            = require('../../src/plugin')
{FitWorkoutFactory} = require('../../src/workouts/fit_workout_factory')
{TcxWorkoutFactory} = require('../../src/workouts/tcx_workout_factory')

describe 'Reader', ->
  beforeEach ->
    @pluginIsInstalledStub = sinon.stub(Plugin.prototype, 'pluginIsInstalled')
    @device = {number: 0}
    @dataType = 'test'
    @pluginMethod = 'Foo'
    @reader = new Reader(@device, @dataType, @pluginMethod)
    @invokeStub = sinon.stub(@reader.communicator, 'invoke')
    @reader.communicator.pluginProxy = {
      StartReadFoo: -> true
      FinishReadFoo: -> true
    }

  afterEach ->
    @pluginIsInstalledStub.restore()
    @invokeStub.restore()
    Communicator.destroy()

  describe '#perform', ->
    it 'throws an error is the plugin is busy', ->
      sinon.stub(Communicator.get(), 'busy').returns true
      expect(=> @reader.perform()).to.throw Error

    it 'returns a promise', ->
      @invokeStub.withArgs('FinishReadFoo').returns 3
      subject = @reader.perform()
      expect(subject? and _(subject).isObject() and subject.isFulfilled?).to.equal true

    it 'invokes the method on the communicator', ->
      @invokeStub.withArgs('FinishReadFoo').returns 3
      @reader.perform()
      expect(@invokeStub.calledWith('StartReadFoo', 0, 'test')).to.equal true

  describe "#clearDeviceXmlBuffers", ->

  describe "#_onFinished", ->

  describe "#handleFinishedReading", ->
    describe "pluginMethod is FITDirectory", ->
      beforeEach ->
        @reader.pluginMethod = "FITDirectory"

      it "calls handleReadFITDirectory when it finishes reading", ->
        handleReadFITDirectoryStub = sinon.stub(@reader, 'handleReadFITDirectory')
        @reader.handleFinishedReading()
        expect(handleReadFITDirectoryStub.calledOnce).to.be.true
        handleReadFITDirectoryStub.restore()

    describe "pluginMethod is FitnessDirectory", ->
      beforeEach ->
        @reader.pluginMethod = "FitnessDirectory"

      it "calls handleReadFitnessDirectory when it finishes reading", ->
        handleReadFitnessDirectoryStub = sinon.stub(@reader, 'handleReadFitnessDirectory')
        @reader.handleFinishedReading()
        expect(handleReadFitnessDirectoryStub.calledOnce).to.be.true
        handleReadFitnessDirectoryStub.restore()

    describe "pluginMethod is FitnessDetail", ->
      beforeEach ->
        @reader.pluginMethod = "FitnessDetail"

      it "it calls handleReadFitnessDetail when it finishes reading", ->
        handleReadFitnessDetailStub = sinon.stub(@reader, 'handleReadFitnessDetail')
        @reader.handleFinishedReading()
        expect(handleReadFitnessDetailStub.calledOnce).to.be.true
        handleReadFitnessDetailStub.restore()

    describe "#handleReadFITDirectory", ->
      beforeEach ->
        @produceStub = sinon.stub(FitWorkoutFactory.prototype, 'produce')
        @readStub = sinon.stub(@reader.communicator, 'read')

      afterEach ->
        @readStub.restore()
        @produceStub.restore()

      it "reads data from the plugin", ->
        @reader.handleReadFITDirectory()
        expect(@readStub.calledWith("DirectoryListingXml")).to.be.true

      it "passes the raw device data to the workout factory", ->
        @readStub.withArgs("DirectoryListingXml").returns("handleReadFITDirectory data")
        @reader.handleReadFITDirectory()
        expect(@produceStub.calledWith("handleReadFITDirectory data")).to.be.true

    describe "#handleReadFitnessDirectory", ->
      beforeEach ->
        @produceStub = sinon.stub(TcxWorkoutFactory.prototype, 'produce')
        @readStub = sinon.stub(@reader.communicator, 'read')

      afterEach ->
        @produceStub.restore()
        @readStub.restore()

      it "reads data from the plugin", ->
        @reader.handleReadFitnessDirectory()
        expect(@readStub.calledWith("TcdXml")).to.be.true

      it "passes the raw device data to the workout factory", ->
        @readStub.withArgs("TcdXml").returns("handleReadFitnessDirectory data")
        @reader.handleReadFitnessDirectory()
        expect(@produceStub.calledWith("handleReadFitnessDirectory data")).to.be.true

    describe "#handleReadFitnessDetail", ->
      beforeEach ->
        @readStub = sinon.stub(@reader.communicator, 'read')

      afterEach ->
        @readStub.restore()

      it "reads data from the plugin", ->
        @reader.handleReadFitnessDetail()
        expect(@readStub.calledWith("TcdXml")).to.be.true
