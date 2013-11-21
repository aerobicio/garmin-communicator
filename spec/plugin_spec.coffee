{Plugin}       = require('../src/plugin')
{Communicator} = require('../src/communicator')

describe 'Plugin', ->
  describe 'Add the plugin element to the DOM', ->
    beforeEach ->
      @_checkIsInstalled = sinon.stub(Plugin.prototype, '_checkIsInstalled')

    afterEach ->
      $("#GarminNetscapePlugin, #GarminActiveXControl, div:empty").remove()
      @_checkIsInstalled.restore()

    describe 'in a modern browser', ->
      beforeEach ->
        @stub = sinon.stub(Plugin.prototype, '_smellsLikeIE').returns false
        @class = new Plugin

      afterEach ->
        @stub.restore()

      it 'creates a communicator object for a good browser', ->
        expect(@class.el.id).to.equal "GarminNetscapePlugin"

    describe 'in internet explorer', ->
      beforeEach ->
        @stub = sinon.stub(Plugin.prototype, '_smellsLikeIE').returns true
        @class = new Plugin

      afterEach ->
        @stub.restore()

      it 'creates a communicator object for a garbage browser', ->
        expect(@class.el.id).to.equal "GarminActiveXControl"

  describe 'Check that the plugin is installed', ->
    beforeEach ->
      @_checkIsInstalled = sinon.spy(Plugin.prototype, '_checkIsInstalled')

    afterEach ->
      @_checkIsInstalled.restore()

    it 'checks that the plugin is installed', ->
      sinon.stub(Plugin.prototype, '_createPluginEl').returns { Unlock: -> true }
      new Communicator
      expect(@_checkIsInstalled.calledOnce).to.equal true

    it 'throws an error if the plugin is not installed', ->
      expect(=> new Communicator).to.throw. Error
