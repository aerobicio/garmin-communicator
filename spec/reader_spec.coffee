{Reader}       = require('../src/device/reader')
{Communicator} = require('../src/communicator')

describe 'Reader', ->
  beforeEach ->
    @communicator             = Communicator.get()
    @device                   = {number: 0}
    @dataType                 = 'test'
    @pluginMethod             = 'Foo'
    @reader                   = new Reader(@device, @dataType, @pluginMethod)
    @communicator.pluginProxy = {StartReadFoo: -> true}
    @invokeSpy                = sinon.spy(@communicator, 'invoke')

  afterEach ->
    Communicator.destroy()
    @invokeSpy.restore()

  describe '#perform', ->
    it 'throws an error is the plugin is busy', ->
      sinon.stub(Communicator.get(), 'busy').returns true
      expect(=> @reader.perform()).to.throw Error

    it 'returns a promise', ->
      subject = @reader.perform()
      expect(subject? and _(subject).isObject() and subject.isFulfilled?).to.equal true

    it 'invokes the method on the communicator', ->
      @reader.perform()
      expect(@communicator.invoke.calledWith('StartReadFoo', 0, 'test')).to.equal true
