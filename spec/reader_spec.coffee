{Reader} = require('../src/device/reader')

describe 'Reader', ->
  beforeEach ->
    @pluginDelegate = { busy: -> return }
    @dataType       = 'test'
    @pluginMethod   = 'foo'
    @pluginBusyStub = sinon.stub(@pluginDelegate, 'busy')
    @reader         = new Reader(@pluginDelegate, @dataType, @pluginMethod)

  describe '#perform', ->
    it 'throws an error is the plugin is busy', ->
      @pluginBusyStub.returns true
      expect(=> @reader.perform()).to.throw Error

    it 'returns a promise', ->
      subject = @reader.perform()
      expect(subject? and _(subject).isObject() and subject.isFulfilled?).to.equal true
