{Plugin} = require('../src/plugin')

describe 'Plugin', ->
  describe 'Add the plugin element to the DOM', ->
    afterEach ->
      $("#GarminNetscapePlugin, #GarminActiveXControl, div:empty").remove()

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
