{Garmin}       = require('../src/garmin')
{Communicator} = require('../src/communicator')
{Plugin}       = require('../src/plugin')

describe "Garmin", ->
  beforeEach ->
    @pluginIsInstalledStub = sinon.stub(Plugin.prototype, 'pluginIsInstalled')

  afterEach ->
    Communicator.destroy()
    @pluginIsInstalledStub.restore()

  describe "#mergeUnlockCodes", ->
    it "returns the default unlock codes if none were passed in", ->
      garmin = new window.Garmin()
      chai.expect(garmin.mergeUnlockCodes()).to.equal garmin.DEFAULT_UNLOCK_CODES

    it "returns the default unlock codes merged with ones passed in", ->
      unlockCode = "https://aerobic.io": "velciraptors-are-awesome"
      garmin = new window.Garmin(unlockCodes: unlockCode)
      chai.expect(garmin.mergeUnlockCodes()).to.have.keys([
        "file:///",
        "http://localhost",
        "http://127.0.0.1",
        "https://aerobic.io"
      ])

  describe "#unlock", ->
    beforeEach ->
      @garmin = new window.Garmin()
      @unlockStub = sinon.stub(@garmin.communicator, 'unlock')

    it "unlocks the plugin with the unlock codes", ->
      @garmin.unlock()
      chai.expect(@unlockStub.calledWith(@garmin.DEFAULT_UNLOCK_CODES)).to.be.true

  describe "#devices", ->
    beforeEach ->
      @garmin = new window.Garmin()
      @devicesStub = sinon.stub(@garmin.communicator, 'devices')

    it "gets devices", ->
      @garmin.devices()
      chai.expect(@unlockStub.calledOnce).to.be.true
