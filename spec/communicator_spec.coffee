{Communicator} = require('../src/Communicator')
{Device}       = require('../src/Device')

describe 'Communicator', ->
  describe '#init', ->
    afterEach ->
      $("#GarminNetscapePlugin, #GarminActiveXControl, div:empty").remove()

    it 'will memoise the communicator and return immediately', ->
      subject = new Communicator
      subject.plugin = true
      expect(subject.init()).to.be.true

    describe 'in a modern browser', ->
      beforeEach ->
        @stub = sinon.stub(Communicator.prototype, '_smellsLikeIE').returns false
        @class = new Communicator

      afterEach ->
        @stub.restore()

      it 'creates a communicator object for a good browser', ->
        subject = @class.init()
        expect(subject.id).to.equal "GarminNetscapePlugin"

    describe 'in internet explorer', ->
      beforeEach ->
        @stub = sinon.stub(Communicator.prototype, '_smellsLikeIE').returns true
        @class = new Communicator

      afterEach ->
        @stub.restore()

      it 'creates a communicator object for a garbage browser', ->
        subject = @class.init()
        expect(subject.id).to.equal "GarminActiveXControl"

  describe '#busy', ->
    beforeEach ->
      @initStub = sinon.stub(Communicator.prototype, 'init')
      @communicator = new Communicator

    afterEach ->
      @initStub.restore()

    it 'is not busy by default', ->
      expect(@communicator.busy()).to.be_false

    it 'returns the current state of the property, or sets it', ->
      @communicator.busy(yes)
      expect(@communicator.busy()).to.be_true

      @communicator.busy(no)
      expect(@communicator.busy()).to.be_false

      expect(@communicator.busy(yes)).to.be_true

  describe '#isLocked', ->
    beforeEach ->
      @initStub = sinon.stub(Communicator.prototype, 'init')
      @communicator = new Communicator
      @plugin = { Locked: -> return }

    afterEach ->
      @initStub.restore()

    it 'returns true if the plugin is locked', ->
      sinon.stub(@plugin, 'Locked').returns true
      @communicator.plugin = @plugin
      expect(@communicator.isLocked()).to.be_true

    it 'returns false if the plugin is unlocked', ->
      sinon.stub(@plugin, 'Locked').returns false
      @communicator.plugin = @plugin
      expect(@communicator.isLocked()).to.be_false

  describe '#unlock', ->
    beforeEach ->
      @initStub = sinon.stub(Communicator.prototype, 'init')
      @communicator = new Communicator
      @plugin = { Locked: -> return }

    afterEach ->
      @initStub.restore()

    it 'does nothing if already unlocked', ->
      sinon.stub(@plugin, 'Locked').returns false
      @communicator.plugin = @plugin
      expect(@communicator.unlock()).to.be_null

    describe 'unlocking the plugin', ->
      it 'returns true when it unlocks the plugin successfully', ->
        sinon.stub(@plugin, 'Locked').returns false
        @communicator.plugin = @plugin
        expect(@communicator.unlock()).to.be_true

      xit 'throws an exception if the plugin fails to unlock'

  describe '#devices', ->
    beforeEach ->
      @initStub = sinon.stub(Communicator.prototype, 'init')
      @communicator = new Communicator
      # mock out the plugin interface
      plugin = {
        StartFindDevices: -> return
        FinishFindDevices: -> return
        DevicesXmlString: -> return
      }
      @StartFindDevicesStub      = sinon.stub(plugin, 'StartFindDevices')
      @FinishFindDevicesStub     = sinon.stub(plugin, 'FinishFindDevices').returns true
      @DevicesXmlStringStub      = sinon.stub(plugin, 'DevicesXmlString').returns 'text'
      @communicator.plugin       = plugin

    afterEach ->
      @initStub.restore()
      @StartFindDevicesStub.restore()
      @FinishFindDevicesStub.restore()
      @DevicesXmlStringStub.restore()
      @communicator = null

    it 'it will unlock the communicator if it is not already unlocked', ->
      @isLockedStub = sinon.stub(@communicator, 'isLocked').returns true
      @unlockStub = sinon.stub(@communicator, 'unlock')
      @communicator.devices()
      expect(@unlockStub.calledOnce).to.be_true

    it 'returns a promise', ->
      subject = @communicator.devices()
      expect(subject.isDeferred).to.be_true

    it 'marks the communicator as being busy', ->
      @communicator.devices()
      expect(@communicator.isBusy).to.be_true

    it 'marks the communicator as being inactive once the promise is called', ->
      @FinishFindDevicesStub.returns false
      @communicator.devices()
      expect(@communicator.isBusy).to.be_true
      @FinishFindDevicesStub.returns true
      expect(@communicator.isBusy).to.be_false

    describe 'when the plugin is already busy', ->
      it 'does nothing', ->
        subject = @communicator.devices()
        expect(subject).to.be_null

    describe 'when the plugin finishes finding devices', ->
      beforeEach ->
        @clock = sinon.useFakeTimers()

      afterEach ->
        @clock.restore()

      it 'will keeping checking until the communicator is finished loading every 100ms', ->
        @communicator.devices()
        expect(@communicator._loopUntilFinishedFindingDevices.calledOnce).to.be_true
        @clock.tick(100)
        expect(@communicator._loopUntilFinishedFindingDevices.calledTwice).to.be_true
        @clock.tick(100)
        expect(@communicator._loopUntilFinishedFindingDevices.calledThrice).to.be_true

      describe 'xml', ->
        beforeEach ->
          @deviceInitStub            = sinon.stub(Device.prototype, 'init')
          @clock                     = sinon.useFakeTimers()
          @data                      = null
          @FinishFindDevicesResponse = true
          @DevicesXmlStringResponse  = 'text'

        afterEach ->
          @clock.restore()
          @initStub.restore()
          @deviceInitStub.restore()

        it 'returns an empty array if there are no devices found', ->
          @clock.tick(100)
          @DevicesXmlStringStub.returns """
            <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
            <Devices xmlns="http://www.garmin.com/xmlschemas/PluginAPI/v1">
            </Devices>
          """
          subject = @communicator.devices()
          subject.next (data) ->
            expect(data).to.equal []

          @FinishFindDevicesStub.returns true

        it 'returns an array of devices', ->
          @DevicesXmlStringStub.returns """
            <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
            <Devices xmlns="http://www.garmin.com/xmlschemas/PluginAPI/v1">
              <Device DisplayName="Edge 500" Number="0"/>
              <Device DisplayName="Edge 510" Number="1"/>
            </Devices>
          """
          @FinishFindDevicesStub.returns false
          subject = @communicator.devices()
          subject.next (data) => @data = data
          @FinishFindDevicesStub.returns true
          @clock.tick(100)

          expect(@data.length).to.equal 2
          expect(@data[0].name).to.equal "Edge 500"
          expect(@data[0].number).to.equal 0
          expect(@data[1].name).to.equal "Edge 510"
          expect(@data[1].number).to.equal 1
