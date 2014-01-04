{Plugin}       = require('../src/plugin')
{Communicator} = require('../src/communicator')

describe 'Plugin', ->
  describe 'Add the plugin element to the DOM', ->
    beforeEach ->
      @pluginIsInstalledSpy = sinon.spy(Plugin.prototype, 'pluginIsInstalled')

    afterEach ->
      $("#GarminNetscapePlugin, #GarminActiveXControl, div:empty").remove()
      @pluginIsInstalledSpy.restore()

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

  describe '#pluginIsInstalled', ->
    beforeEach ->
      @pluginIsInstalledSpy = sinon.spy(Plugin.prototype, 'pluginIsInstalled')
      @plugin = new Plugin

    afterEach ->
      Communicator.destroy()
      @pluginIsInstalledSpy.restore()

    it 'checks that the plugin is installed', ->
      Communicator.get()
      expect(@pluginIsInstalledSpy.calledOnce).to.equal true

    it 'returns true if the plugin is installed', ->
      @plugin.el.Unlock = -> true
      Communicator.get()
      expect(@plugin.pluginIsInstalled()).to.be.true

    it 'returns false if the plugin is not installed', ->
      expect(@plugin.pluginIsInstalled()).to.be.false
