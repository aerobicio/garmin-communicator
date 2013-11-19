{Communicator} = require('../src/communicator')
{Device}       = require('../src/device')

describe 'Communicator', ->
  afterEach ->
    $("#GarminNetscapePlugin, #GarminActiveXControl, div:empty").remove()

  describe 'garmin plugin installation', ->
    beforeEach ->
      @checkIsInstalledSpy = sinon.spy(Communicator.prototype, '_checkIsInstalled')
      @initPluginStub = sinon.stub(Communicator.prototype, '_initPlugin')

    afterEach ->
      @checkIsInstalledSpy.restore()
      @initPluginStub.restore()

    it 'checks that the plugin is installed', ->
      @initPluginStub.returns {Unlock: sinon.spy}
      subject = new Communicator
      expect(@checkIsInstalledSpy.calledOnce).to.equal true

    it 'throws an error if the plugin is not installed', ->
      expect(=> new Communicator).to.throw. Error

  describe 'initialising the plugin', ->
    beforeEach ->
      @checkIsInstalledStub = sinon.stub(Communicator.prototype, '_checkIsInstalled')

    afterEach ->
      @checkIsInstalledStub.restore()

    describe 'in a modern browser', ->
      beforeEach ->
        @stub = sinon.stub(Communicator.prototype, '_smellsLikeIE').returns false
        @class = new Communicator

      afterEach ->
        @stub.restore()

      it 'creates a communicator object for a good browser', ->
        expect(@class.plugin.id).to.equal "GarminNetscapePlugin"

    describe 'in internet explorer', ->
      beforeEach ->
        @stub = sinon.stub(Communicator.prototype, '_smellsLikeIE').returns true
        @class = new Communicator

      afterEach ->
        @stub.restore()

      it 'creates a communicator object for a garbage browser', ->
        expect(@class.plugin.id).to.equal "GarminActiveXControl"

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
      @clock = sinon.useFakeTimers()
      @setDeviceInfoStub = sinon.stub(Device.prototype, '_setDeviceInfo')
      @initStub = sinon.stub(Communicator.prototype, 'init')
      @communicator = new Communicator
      # mock out the plugin interface
      plugin = {
        StartFindDevices:  -> return
        FinishFindDevices: -> return
        DevicesXmlString:  -> return
        DeviceDescription: -> return
      }
      @startFindDevicesStub  = sinon.stub(plugin, 'StartFindDevices')
      @finishFindDevicesStub = sinon.stub(plugin, 'FinishFindDevices')
      @devicesXmlStringStub  = sinon.stub(plugin, 'DevicesXmlString')
      @deviceDescriptionStub = sinon.stub(plugin, 'DeviceDescription')
      @communicator.plugin   = plugin

    afterEach ->
      @clock.restore()
      @initStub.restore()
      @setDeviceInfoStub.restore()
      @startFindDevicesStub.restore()
      @finishFindDevicesStub.restore()
      @devicesXmlStringStub.restore()
      @deviceDescriptionStub.restore()
      @communicator = null

    it 'it will unlock the communicator if it is not already unlocked', ->
      sinon.stub(@communicator, 'isLocked').returns true
      sinon.stub(@communicator, 'busy').returns false
      unlockStub = sinon.stub(@communicator, 'unlock')
      @communicator.devices()
      expect(unlockStub.calledOnce).to.equal true

    it 'returns a promise', ->
      @finishFindDevicesStub.returns true
      subject = @communicator.devices()
      expect(subject? and _(subject).isObject() and subject.isFulfilled?).to.equal true

    it 'marks the communicator as being busy', ->
      @communicator.devices()
      expect(@communicator.busy()).to.equal true

    it 'marks the communicator as being inactive once the promise is called', (done) ->
      @finishFindDevicesStub.returns false

      # When the promise is resolved then it should no longer be busy.
      promise = @communicator.devices().finally =>
        expect(@communicator.busy()).to.equal false
        done()

      expect(@communicator.busy()).to.equal true

      # Ensure that the promise resolves.
      @finishFindDevicesStub.returns true
      @clock.tick(100)
      promise

    describe 'when the plugin is already busy', ->
      it 'does nothing', ->
        sinon.stub(@communicator, 'busy').returns true
        subject = @communicator.devices()
        expect(subject).to.equal undefined

    describe 'when the plugin finishes finding devices', ->
      it 'will keeping checking until the communicator is finished loading every 100ms', (done) ->
        @finishFindDevicesStub.returns false
        loopUntilFinishedFindingDevicesSpy = sinon.spy(@communicator, '_loopUntilFinishedFindingDevices')
        promise = @communicator.devices().finally -> done()

        expect(loopUntilFinishedFindingDevicesSpy.calledOnce).to.equal true
        @clock.tick(100)
        expect(loopUntilFinishedFindingDevicesSpy.calledTwice).to.equal true
        @clock.tick(100)
        expect(loopUntilFinishedFindingDevicesSpy.calledThrice).to.equal true

        # Ensure the promise is kept.
        @finishFindDevicesStub.returns true
        @clock.tick(100)
        promise

      describe 'xml', ->
        it 'returns an empty array if there are no devices found', (done) ->
          @devicesXmlStringStub.returns """
            <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
            <Devices>
            </Devices>
          """
          @finishFindDevicesStub.returns false
          promise = @communicator.devices().then (data) =>
            expect(data).to.be.empty
            done()

          @finishFindDevicesStub.returns true
          @clock.tick(100)

          promise

        it 'returns an array of devices', (done) ->
          @devicesXmlStringStub.returns """
            <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
            <Devices>
              <Device DisplayName="Edge 500" Number="0"/>
              <Device DisplayName="Edge 510" Number="1"/>
              <Device DisplayName="Garmin Swim" Number="2"/>
            </Devices>
          """
          @finishFindDevicesStub.returns false
          promise = @communicator.devices().then (data) =>
            expect(data.length).to.equal 3
            expect(data[0].name).to.equal "Edge 500"
            expect(data[0].number).to.equal 0
            expect(data[1].name).to.equal "Edge 510"
            expect(data[1].number).to.equal 1
            expect(data[2].name).to.equal "Garmin Swim"
            expect(data[2].number).to.equal 2
            done()

          @finishFindDevicesStub.returns true
          @clock.tick(100)

          promise
