{Accessor} = require('../../src/device/accessor')
{Communicator} = require('../../src/communicator')
{Plugin} = require('../../src/plugin')

describe 'accessor', ->
  beforeEach ->
    @pluginIsInstalledStub = sinon.stub(Plugin.prototype, 'pluginIsInstalled')
    @deviceNumber = 0
    @dataType = 'test'
    @pluginMethod = 'Foo'
    @accessor = new Accessor(@deviceNumber, @dataType, @pluginMethod)
    @invokeStub = sinon.stub(@accessor.communicator, 'invoke')

  afterEach ->
    @pluginIsInstalledStub.restore()
    @invokeStub.restore()
    Communicator.destroy()

  describe '#perform', ->
    it 'throws an error if the communicator is busy', ->
      sinon.stub(Communicator.get(), 'busy').returns true
      expect(=> @accessor.perform()).to.throw Error

    it 'returns a promise', ->
      @invokeStub.withArgs('FinishReadFoo').returns 3
      subject = @accessor.perform()
      expect(subject? and _(subject).isObject() and subject.isFulfilled?).to.equal true

    it 'starts checking for the invoked actions finished state'

    describe 'invoking the action on the communicator', ->
      it 'applies using the plugin start action'
      it 'applies using the device number'
      it 'applies using the data type'
      it 'applies using the arguments passed in to perform'

  describe '#_startPluginAction', ->
    it 'returns the method name for starting the action'

  describe '#_finishPluginAction', ->
    it 'returns the method name for finishing the action'

  describe '#_startCheckFinished', ->
    describe 'working', ->
      it 'calls the onWorking handler with the promise'

    describe 'finished', ->
      it 'calls the onFinishe handler with the promise'

    describe 'waiting', ->
      it 'calls the onWaiting handler with the promise'

    describe 'idle', ->
      it 'calls the onIdle handler with the promise'

    describe 'default', ->
      it 'throws an error'

  describe '#_onWorking', ->
    it 'notifies the deferred of progress'
    it 'calls _startCheckFinished()'

  describe '#_onWaiting', ->
    it 'calls _startCheckFinished()'

  describe '#_onIdle', ->
    it 'rejects the promise'
