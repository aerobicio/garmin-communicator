{Communicator} = require('../src/communicator')
{Device}       = require('../src/device')
{Plugin}       = require('../src/plugin')
{Reader}       = require('../src/device/reader')

describe 'Device', ->
  beforeEach ->
    @checkIsInstalledStub = sinon.stub(Plugin.prototype, 'checkIsInstalled')
    @communicator = Communicator.get()
    @invokeStub = sinon.stub(@communicator, 'invoke')
    @communicator.invoke.withArgs('DeviceDescription', 0).returns """
      <?xml version="1.0" ?>
      <Device>
        <Model>
          <PartNumber>006-B1036-00</PartNumber>
          <SoftwareVersion>300</SoftwareVersion>
          <Description>Edge 500</Description>
        </Model>
        <Id>3831132051</Id>
      </Device>
    """
    @device = new Device(0, '')

  afterEach ->
    @checkIsInstalledStub.restore()
    @invokeStub.restore()
    @communicator = Communicator.destroy()

  it 'sets the device id', ->
    expect(@device.id).to.equal "3831132051"

  it 'sets the device name', ->
    expect(@device.name).to.equal "Edge 500"

  it 'sets the device part number', ->
    expect(@device.partNumber).to.equal "006-B1036-00"

  it 'sets the device software version', ->
    expect(@device.softwareVersion).to.equal "300"

  describe '#activities', ->
    describe 'the device can read FIT activities', ->
      it 'reads FIT activities', ->
        @device.canReadFITActivities = true
        @device.readFITActivities = sinon.stub()
        @device.activities()
        chai.expect(@device.readFITActivities.calledOnce).to.be.true

    describe 'the device cannot read FIT activities', ->
      it 'reads TCX activities', ->
        @device.canReadFITActivities = false
        @device.readActivities = sinon.stub()
        @device.activities()
        chai.expect(@device.readActivities.calledOnce).to.be.true

  describe 'Capabilities', ->
    beforeEach ->
      @_setDeviceInfoStub = sinon.stub(Device.prototype, '_setDeviceInfo')

    afterEach ->
      @_setDeviceInfoStub.restore()

    describe '.canReadActivities', ->
      it 'is false by default', ->
        device = new Device(0, '')
        expect(device.canReadActivities).to.equal false

      it 'returns true if the device can read workouts', ->
        @communicator.invoke.withArgs('DeviceDescription', 0).returns """
          <?xml version="1.0" ?>
          <Device>
            <MassStorageMode>
              <DataType>
                <Name>FitnessHistory</Name>
                <File>
                  <TransferDirection>OutputFromUnit</TransferDirection>
                </File>
              </DataType>
            </MassStorageMode>
          </Device>
        """
        device = new Device(0, '')
        expect(device.canReadActivities).to.equal true

    describe '.canWriteActivities', ->
      it 'is false by default', ->
        device = new Device(0, '')
        expect(device.canWriteActivities).to.equal false

      it 'returns true if the device can write workouts', ->
        @communicator.invoke.withArgs('DeviceDescription', 0).returns """
          <?xml version="1.0" ?>
          <Device>
            <MassStorageMode>
              <DataType>
                <Name>FitnessHistory</Name>
                <File>
                  <TransferDirection>InputToUnit</TransferDirection>
                </File>
              </DataType>
            </MassStorageMode>
          </Device>
        """
        device = new Device(0, '')
        expect(device.canWriteActivities).to.equal true

    describe '.canReadWorkouts', ->
      it 'is false by default', ->
        device = new Device(0, '')
        expect(device.canReadWorkouts).to.equal false

      it 'returns true if the device can read workouts', ->
        @communicator.invoke.withArgs('DeviceDescription', 0).returns """
          <?xml version="1.0" ?>
          <Device>
            <MassStorageMode>
              <DataType>
                <Name>FitnessWorkouts</Name>
                <File>
                  <TransferDirection>OutputFromUnit</TransferDirection>
                </File>
              </DataType>
            </MassStorageMode>
          </Device>
        """
        device = new Device(0, '')
        expect(device.canReadWorkouts).to.equal true

    describe '.canWriteWorkouts', ->
      it 'is false by default', ->
        device = new Device(0, '')
        expect(device.canWriteWorkouts).to.equal false

      it 'returns true if the device can write workouts', ->
        @communicator.invoke.withArgs('DeviceDescription', 0).returns """
          <?xml version="1.0" ?>
          <Device>
            <MassStorageMode>
              <DataType>
                <Name>FitnessWorkouts</Name>
                <File>
                  <TransferDirection>InputToUnit</TransferDirection>
                </File>
              </DataType>
            </MassStorageMode>
          </Device>
        """
        device = new Device(0, '')
        expect(device.canWriteWorkouts).to.equal true

    describe '.canReadCourses', ->
      it 'is false by default', ->
        device = new Device(0, '')
        expect(device.canReadCourses).to.equal false

      it 'returns true if the device can read courses', ->
        @communicator.invoke.withArgs('DeviceDescription', 0).returns """
          <?xml version="1.0" ?>
          <Device>
            <MassStorageMode>
              <DataType>
                <Name>FitnessCourses</Name>
                <File>
                  <TransferDirection>OutputFromUnit</TransferDirection>
                </File>
              </DataType>
            </MassStorageMode>
          </Device>
        """
        device = new Device(0, '')
        expect(device.canReadCourses).to.equal true

    describe '.canWriteCourses', ->
      it 'is false by default', ->
        device = new Device(0, '')
        expect(device.canWriteCourses).to.equal false

      it 'returns true if the device can write courses', ->
        @communicator.invoke.withArgs('DeviceDescription', 0).returns """
          <?xml version="1.0" ?>
          <Device>
            <MassStorageMode>
              <DataType>
                <Name>FitnessCourses</Name>
                <File>
                  <TransferDirection>InputToUnit</TransferDirection>
                </File>
              </DataType>
            </MassStorageMode>
          </Device>
        """
        device = new Device(0, '')
        expect(device.canWriteCourses).to.equal true

    describe '.canReadGoals', ->
      it 'is false by default', ->
        device = new Device(0, '')
        expect(device.canReadGoals).to.equal false

      it 'returns true if the device can read goals', ->
        @communicator.invoke.withArgs('DeviceDescription', 0).returns """
          <?xml version="1.0" ?>
          <Device>
            <MassStorageMode>
              <DataType>
                <Name>FitnessActivityGoals</Name>
                <File>
                  <TransferDirection>OutputFromUnit</TransferDirection>
                </File>
              </DataType>
            </MassStorageMode>
          </Device>
        """
        device = new Device(0, '')
        expect(device.canReadGoals).to.equal true

    describe '.canWriteGoals', ->
      it 'is false by default', ->
        device = new Device(0, '')
        expect(device.canWriteGoals).to.equal false

      it 'returns true if the device can write goals', ->
        @communicator.invoke.withArgs('DeviceDescription', 0).returns """
          <?xml version="1.0" ?>
          <Device>
            <MassStorageMode>
              <DataType>
                <Name>FitnessActivityGoals</Name>
                <File>
                  <TransferDirection>InputToUnit</TransferDirection>
                </File>
              </DataType>
            </MassStorageMode>
          </Device>
        """
        device = new Device(0, '')
        expect(device.canWriteGoals).to.equal true

    describe '.canReadProfile', ->
      it 'is false by default', ->
        device = new Device(0, '')
        expect(device.canReadProfile).to.equal false

      it 'returns true if the device can read profiles', ->
        @communicator.invoke.withArgs('DeviceDescription', 0).returns """
          <?xml version="1.0" ?>
          <Device>
            <MassStorageMode>
              <DataType>
                <Name>FitnessUserProfile</Name>
                <File>
                  <TransferDirection>OutputFromUnit</TransferDirection>
                </File>
              </DataType>
            </MassStorageMode>
          </Device>
        """
        device = new Device(0, '')
        expect(device.canReadProfile).to.equal true

    describe '.canWriteProfile', ->
      it 'is false by default', ->
        device = new Device(0, '')
        expect(device.canWriteProfile).to.equal false

      it 'returns true if the device can write profiles', ->
        @communicator.invoke.withArgs('DeviceDescription', 0).returns """
          <?xml version="1.0" ?>
          <Device>
            <MassStorageMode>
              <DataType>
                <Name>FitnessUserProfile</Name>
                <File>
                  <TransferDirection>InputToUnit</TransferDirection>
                </File>
              </DataType>
            </MassStorageMode>
          </Device>
        """
        device = new Device(0, '')
        expect(device.canWriteProfile).to.equal true

    describe '.canReadFITActivities', ->
      it 'is false by default', ->
        device = new Device(0, '')
        expect(device.canReadFITActivities).to.equal false

      it 'returns true if the device can read FIT activities', ->
        @communicator.invoke.withArgs('DeviceDescription', 0).returns """
          <?xml version="1.0" ?>
          <Device>
            <MassStorageMode>
              <DataType>
                <Name>FIT_TYPE_4</Name>
                <File>
                  <TransferDirection>OutputFromUnit</TransferDirection>
                </File>
              </DataType>
            </MassStorageMode>
          </Device>
        """
        device = new Device(0, '')
        expect(device.canReadFITActivities).to.equal true

    describe '.canWriteFITActivities', ->
      it 'is false by default', ->
        device = new Device(0, '')
        expect(device.canWriteFITActivities).to.equal false

      it 'returns true if the device can write FIT activities', ->
        @communicator.invoke.withArgs('DeviceDescription', 0).returns """
          <?xml version="1.0" ?>
          <Device>
            <MassStorageMode>
              <DataType>
                <Name>FIT_TYPE_4</Name>
                <File>
                  <TransferDirection>InputToUnit</TransferDirection>
                </File>
              </DataType>
            </MassStorageMode>
          </Device>
        """
        device = new Device(0, '')
        expect(device.canWriteFITActivities).to.equal true

  describe 'Data Access', ->
    beforeEach ->
      @_setDeviceInfoStub = sinon.stub(Device.prototype, '_setDeviceInfo')

    afterEach ->
      @_setDeviceInfoStub.restore()

    describe 'Reading data', ->
      beforeEach ->
        @handleFinishedReading = sinon.stub(Reader.prototype, 'handleFinishedReading')

      afterEach ->
        @handleFinishedReading.restore()

      describe '#readActivities', ->
        it 'throws an exception if the device does not support the action', ->
          @device.canReadActivities = false
          expect(=> @device.readActivities()).to.throw Error

        it 'returns a promise of data', ->
          @communicator.invoke.withArgs('FinishReadFitnessDirectory').returns 3
          @device.canReadActivities = true
          promise = @device.readActivities()
          expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

      describe '#readWorkouts', ->
        it 'throws an exception if the device does not support the action', ->
          @device.canReadWorkouts = false
          expect(=> @device.readWorkouts()).to.throw Error

        it 'returns a promise of data', ->
          @communicator.invoke.withArgs('FinishReadFitnessData').returns 3
          @device.canReadWorkouts = true
          promise = @device.readWorkouts()
          expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

      describe '#readCourses', ->
        it 'throws an exception if the device does not support the action', ->
          @device.canReadCourses = false
          expect(=> @device.readCourses()).to.throw Error

        it 'returns a promise of data', ->
          @communicator.invoke.withArgs('FinishReadFitnessData').returns 3
          @device.canReadCourses = true
          promise = @device.readCourses()
          expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

      describe '#readGoals', ->
        it 'throws an exception if the device does not support the action', ->
          @device.canReadGoals = false
          expect(=> @device.readGoals()).to.throw Error

        it 'returns a promise of data', ->
          @communicator.invoke.withArgs('FinishReadFitnessData').returns 3
          @device.canReadGoals = true
          promise = @device.readGoals()
          expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

      describe '#readProfile', ->
        it 'throws an exception if the device does not support the action', ->
          @device.canReadProfile = false
          expect(=> @device.readProfile()).to.throw Error

        it 'returns a promise of data', ->
          @communicator.invoke.withArgs('FinishReadFitnessData').returns 3
          @device.canReadProfile = true
          promise = @device.readProfile()
          expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

      describe '#readFITActivities', ->
        beforeEach ->
          @readStub = sinon.stub(@communicator, 'read')
          @communicator.read.withArgs('DirectoryListingXml').returns """
            <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
            <DirectoryListing xmlns="http://www.garmin.com/xmlschemas/DirectoryListing/v1" RequestedPath="" UnitId="3856053743" VolumePrefix="">
              <File IsDirectory="false" Path="Activities/20130305-210510-1-1499-ANTFS-4-0.FIT">
                <CreationTime>2013-03-05T10:05:10Z</CreationTime>
                <FitId>
                  <Id>731412310</Id>
                  <FileType>4</FileType>
                  <Manufacturer>1</Manufacturer>
                  <Product>1499</Product>
                  <SerialNumber>3856053743</SerialNumber>
                  <FileNumber>0</FileNumber>
                </FitId>
              </File>
            </DirectoryListing>
          """

        afterEach ->
          @readStub.restore()

        it 'throws an exception if the device does not support the action', ->
          @device.canReadFITActivities = false
          expect(=> @device.readFITActivities()).to.throw Error

        it 'returns a promise of data', ->
          @communicator.invoke.withArgs('FinishReadFITDirectory').returns 3
          @device.canReadFITActivities = true
          promise = @device.readFITActivities()
          expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

    describe 'Writing data', ->
      describe '#writeActivities', ->
        it 'is not implemented and throws an exception', ->
          expect(=> @device.writeActivities()).to.throw Error

      describe '#writeWorkouts', ->
        it 'is not implemented and throws an exception', ->
          expect(=> @device.writeWorkouts()).to.throw Error

      describe '#writeCourses', ->
        it 'is not implemented and throws an exception', ->
          expect(=> @device.writeCourses()).to.throw Error

      describe '#writeGoals', ->
        it 'is not implemented and throws an exception', ->
          expect(=> @device.writeGoals()).to.throw Error

      describe '#writeProfile', ->
        it 'is not implemented and throws an exception', ->
          expect(=> @device.writeProfile()).to.throw Error

      describe '#writeFITActivities', ->
        it 'is not implemented and throws an exception', ->
          expect(=> @device.writeFITActivities()).to.throw Error
