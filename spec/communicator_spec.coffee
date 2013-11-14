{Communicator} = require('../src/Communicator')

describe 'Communicator', ->
  describe '#initCommunicator', ->
    afterEach ->
      $("#GarminNetscapePlugin, #GarminActiveXControl, div:empty").remove()

    it 'will memoise the communicator and return immediately', ->
      subject = new Communicator
      subject.communicator = true
      expect(subject.initCommunicator()).to.be.true

    describe 'in a modern browser', ->
      beforeEach ->
        @stub = sinon.stub(Communicator.prototype, '_smellsLikeIE').returns false
        @class = new Communicator

        afterEach ->
          @stub.restore()

      it 'creates a communicator object', ->
        subject = @class.initCommunicator()
        expect(subject.id).to.equal "GarminNetscapePlugin"

    describe 'in internet explorer', ->
      beforeEach ->
        @class = new Communicator
        @stub = sinon.stub(Communicator.prototype, '_smellsLikeIE').returns true

      afterEach ->
        @stub.restore()

      it 'creates a communicator object', ->
        subject = @class.initCommunicator()
        expect(subject.id).to.equal "GarminActiveXControl"

  describe '#isLocked', ->
    xit 'returns true if the plugin is locked'
    xit 'returns false if the plugin is unlocked'

  describe '#unlock', ->
    xit 'does nothing if already unlocked'

  describe '#findDevices', ->
    beforeEach ->
      @initCommunicatorStub = sinon.stub(Communicator.prototype, 'initCommunicator')
      @communicator = new Communicator
      @communicator.communicator = sinon.stub()


    it 'it will unlock the communicator is it is not already unlocked', ->
      @communicator = new Communicator
      @isLockedStub = sinon.stub(@communicator, 'isLocked').returns true
      @unlockStub = sinon.stub(@communicator, 'unlock')
      @communicator.findDevices()

      expect(@unlockStub.called).to.be true

    it 'marks the communicator as being busy', ->

      @communicator.findDevices()

    xit 'returns a promise'

    describe 'when the device finishes finding devices', ->
      xit 'calls the promise with the data'
