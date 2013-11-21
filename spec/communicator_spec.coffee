{Communicator} = require('../src/communicator')
{Plugin}       = require('../src/plugin')
{Device}       = require('../src/device')

describe 'Communicator', ->
  beforeEach ->
    @_checkIsInstalledStub = sinon.stub(Plugin.prototype, '_checkIsInstalled')

  afterEach ->
    @_checkIsInstalledStub.restore()

  describe '#invoke', ->
    beforeEach ->
      @communicator = new Communicator

    it 'calls the function on the pluginProxy'
    it 'throws an error if the method name does not exist'
    it 'throws an error if the method name is not a function of the pluginProxy'

  describe '#busy', ->
    beforeEach ->
      @communicator = new Communicator

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
      @communicator = new Communicator
      @communicator.pluginProxy = {}

    it 'returns true if the plugin is locked', ->
      @communicator.pluginProxy.Locked = true
      expect(@communicator.isLocked()).to.equal true

    it 'returns false if the plugin is unlocked', ->
      @communicator.pluginProxy.Locked = false
      expect(@communicator.isLocked()).to.equal false

  describe '#unlock', ->
    beforeEach ->
      @communicator = new Communicator
      @communicator.pluginProxy = {}

    it 'does nothing if already unlocked', ->
      @communicator.pluginProxy.Locked = false
      expect(@communicator.unlock()).to.equal undefined

    describe 'unlocking the plugin', ->
      beforeEach ->
        @communicator.pluginProxy.Locked = true

      it 'returns true when it unlocks the plugin successfully', ->
        expect(@communicator.unlock()).to.equal true

      xit 'throws an exception if the plugin fails to unlock'

  describe '#devices', ->
    beforeEach ->
      @clock = sinon.useFakeTimers()
      @communicator = new Communicator
      # mock out the plugin interface
      pluginProxy = {
        StartFindDevices:  -> return
        FinishFindDevices: -> return
        DevicesXmlString:  -> return
        DeviceDescription: -> return
      }
      @startFindDevicesStub     = sinon.stub(pluginProxy, 'StartFindDevices')
      @finishFindDevicesStub    = sinon.stub(pluginProxy, 'FinishFindDevices')
      @devicesXmlStringStub     = sinon.stub(pluginProxy, 'DevicesXmlString')
      @communicator.pluginProxy = pluginProxy

    afterEach ->
      @clock.restore()
      @startFindDevicesStub.restore()
      @finishFindDevicesStub.restore()
      @devicesXmlStringStub.restore()
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

    describe 'when the plugin is already busy', ->
      it 'does nothing', ->
        sinon.stub(@communicator, 'busy').returns true
        subject = @communicator.devices()
        expect(subject).to.equal undefined

    describe 'no devices found', ->
      beforeEach ->
        @devicesXmlStringStub.returns """
          <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
          <Devices>
          </Devices>
        """
        @finishFindDevicesStub.returns false

      it 'returns an empty array if there are no devices found', (done) ->
        promise = @communicator.devices().then (data) =>
          expect(data).to.be.empty
          done()

        @finishFindDevicesStub.returns true
        @clock.tick(100)

        promise

      # it 'returns an array of devices', (done) ->
      #   @devicesXmlStringStub.returns """
      #     <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
      #     <Devices>
      #       <Device DisplayName="Edge 500" Number="0"/>
      #       <Device DisplayName="Edge 510" Number="1"/>
      #       <Device DisplayName="Garmin Swim" Number="2"/>
      #     </Devices>
      #   """
      #   @finishFindDevicesStub.returns false
      #   promise = @communicator.devices().then (data) =>
      #     expect(data.length).to.equal 3
      #     expect(data[0].name).to.equal "Edge 500"
      #     expect(data[0].number).to.equal 0
      #     expect(data[1].name).to.equal "Edge 510"
      #     expect(data[1].number).to.equal 1
      #     expect(data[2].name).to.equal "Garmin Swim"
      #     expect(data[2].number).to.equal 2
      #     done()

        #   @finishFindDevicesStub.returns true
        #   @clock.tick(100)

        #   promise
