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
      expect(@communicator.busy()).to.equal false

    it 'returns the current state of the property, or sets it', ->
      @communicator.busy(yes)
      expect(@communicator.busy()).to.equal true

      @communicator.busy(no)
      expect(@communicator.busy()).to.equal false

      expect(@communicator.busy(yes)).to.equal true

  describe '#isLocked', ->
    beforeEach ->
      @initStub = sinon.stub(Communicator.prototype, 'init')
      @communicator = new Communicator
      @communicator.plugin = {}

    afterEach ->
      @initStub.restore()

    it 'returns true if the plugin is locked', ->
      @communicator.plugin.Locked = true
      expect(@communicator.isLocked()).to.equal true

    it 'returns false if the plugin is unlocked', ->
      @communicator.plugin.Locked = false
      expect(@communicator.isLocked()).to.equal false

  describe '#unlock', ->
    beforeEach ->
      @initStub = sinon.stub(Communicator.prototype, 'init')
      @communicator = new Communicator
      @communicator.plugin = {}

    afterEach ->
      @initStub.restore()

    it 'does nothing if already unlocked', ->
      @communicator.plugin.Locked = false
      expect(@communicator.unlock()).to.equal undefined

    describe 'unlocking the plugin', ->
      beforeEach ->
        @communicator.plugin.Locked = true

      it 'returns true when it unlocks the plugin successfully', ->
        expect(@communicator.unlock()).to.equal true

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
      @busyStub = sinon.stub(@communicator, 'busy').returns false
      @unlockStub = sinon.stub(@communicator, 'unlock')
      @communicator.devices()
      expect(@unlockStub.calledOnce).to.equal true

    it 'returns a promise', ->
      subject = @communicator.devices()
      expect(subject? and _(subject).isObject and subject.next?).to.equal true

    it 'marks the communicator as being busy', ->
      @communicator.devices()
      expect(@communicator.busy()).to.equal true

    it 'marks the communicator as being inactive once the promise is called', ->
      @communicator.plugin.FinishFindDevices.returns false
      @communicator.devices()
      expect(@communicator.busy()).to.equal true
      @communicator.plugin.FinishFindDevices.returns true
      expect(@communicator.busy()).to.equal false

    describe 'when the plugin is already busy', ->
      it 'does nothing', ->
        subject = @communicator.devices()
        expect(subject).to.equal undefined

    describe 'when the plugin finishes finding devices', ->
      beforeEach ->
        @clock = sinon.useFakeTimers()

      afterEach ->
        @clock.restore()

      it 'will keeping checking until the communicator is finished loading every 100ms', ->
        @communicator.devices()
        expect(@communicator._loopUntilFinishedFindingDevices.calledOnce).to.equal true
        @clock.tick(100)
        expect(@communicator._loopUntilFinishedFindingDevices.calledTwice).to.equal true
        @clock.tick(100)
        expect(@communicator._loopUntilFinishedFindingDevices.calledThrice).to.equal true

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
