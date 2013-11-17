{Communicator} = require('../src/Communicator')
{Device}       = require('../src/Device')

describe 'Device', ->
  describe '#init', ->
    beforeEach ->
      @plugin = {DeviceDescription: -> return}
      sinon.stub(@plugin, 'DeviceDescription').returns """
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
      @device = new Device(@plugin, 0, '')

    it 'sets the device id', ->
      expect(@device.id).to.equal "3831132051"

    it 'sets the device name', ->
      expect(@device.name).to.equal "Edge 500"

    it 'sets the device part number', ->
      expect(@device.partNumber).to.equal "006-B1036-00"

    it 'sets the device software version', ->
      expect(@device.softwareVersion).to.equal "300"

  describe 'capability properties', ->
    beforeEach ->
      @plugin = {DeviceDescription: -> return}
      @getDeviceInfoStub = sinon.stub(Device.prototype, '_getDeviceInfo')
      @DeviceDescriptionStub = sinon.stub(@plugin, 'DeviceDescription').returns ""

    afterEach ->
      @getDeviceInfoStub.restore()
      @DeviceDescriptionStub.restore()
      @device = null

    describe '#canReadActivities', ->
      it 'is false by default', ->
        @device = new Device(@plugin, 0, '')
        expect(@device.canReadActivities).to.equal false

      it 'returns true if the device can read workouts', ->
        @DeviceDescriptionStub.returns """
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
        @device = new Device(@plugin, 0, '')
        expect(@device.canReadActivities).to.equal true

    describe '#canWriteActivities', ->
      it 'is false by default', ->
        @device = new Device(@plugin, 0, '')
        expect(@device.canWriteActivities).to.equal false

      it 'returns true if the device can write workouts', ->
        @DeviceDescriptionStub.returns """
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
        @device = new Device(@plugin, 0, '')
        expect(@device.canWriteActivities).to.equal true

    describe '#canReadWorkouts', ->
      it 'is false by default', ->
        @device = new Device(@plugin, 0, '')
        expect(@device.canReadWorkouts).to.equal false

      it 'returns true if the device can read workouts', ->
        @DeviceDescriptionStub.returns """
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
        @device = new Device(@plugin, 0, '')
        expect(@device.canReadWorkouts).to.equal true

    describe '#canWriteWorkouts', ->
      it 'is false by default', ->
        @device = new Device(@plugin, 0, '')
        expect(@device.canWriteWorkouts).to.equal false

      it 'returns true if the device can write workouts', ->
        @DeviceDescriptionStub.returns """
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
        @device = new Device(@plugin, 0, '')
        expect(@device.canWriteWorkouts).to.equal true

    describe '#canReadCourses', ->
      it 'is false by default', ->
        @device = new Device(@plugin, 0, '')
        expect(@device.canReadCourses).to.equal false

      it 'returns true if the device can read courses', ->
        @DeviceDescriptionStub.returns """
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
        @device = new Device(@plugin, 0, '')
        expect(@device.canReadCourses).to.equal true

    describe '#canWriteCourses', ->
      it 'is false by default', ->
        @device = new Device(@plugin, 0, '')
        expect(@device.canWriteCourses).to.equal false

      it 'returns true if the device can write courses', ->
        @DeviceDescriptionStub.returns """
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
        @device = new Device(@plugin, 0, '')
        expect(@device.canWriteCourses).to.equal true

    describe '#canReadGoals', ->
      it 'is false by default', ->
        @device = new Device(@plugin, 0, '')
        expect(@device.canReadGoals).to.equal false

      it 'returns true if the device can read goals', ->
        @DeviceDescriptionStub.returns """
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
        @device = new Device(@plugin, 0, '')
        expect(@device.canReadGoals).to.equal true

    describe '#canWriteGoals', ->
      it 'is false by default', ->
        @device = new Device(@plugin, 0, '')
        expect(@device.canWriteGoals).to.equal false

      it 'returns true if the device can write goals', ->
        @DeviceDescriptionStub.returns """
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
        @device = new Device(@plugin, 0, '')
        expect(@device.canWriteGoals).to.equal true

    describe '#canReadProfile', ->
      it 'is false by default', ->
        @device = new Device(@plugin, 0, '')
        expect(@device.canReadProfile).to.equal false

      it 'returns true if the device can read profiles', ->
        @DeviceDescriptionStub.returns """
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
        @device = new Device(@plugin, 0, '')
        expect(@device.canReadProfile).to.equal true

    describe '#canWriteProfile', ->
      it 'is false by default', ->
        @device = new Device(@plugin, 0, '')
        expect(@device.canWriteProfile).to.equal false

      it 'returns true if the device can write profiles', ->
        @DeviceDescriptionStub.returns """
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
        @device = new Device(@plugin, 0, '')
        expect(@device.canWriteProfile).to.equal true

    describe '#canReadFITActivities', ->
      it 'is false by default', ->
        @device = new Device(@plugin, 0, '')
        expect(@device.canReadFITActivities).to.equal false

      it 'returns true if the device can read FIT activities', ->
        @DeviceDescriptionStub.returns """
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
        @device = new Device(@plugin, 0, '')
        expect(@device.canReadFITActivities).to.equal true

    describe '#canWriteFITActivities', ->
      it 'is false by default', ->
        @device = new Device(@plugin, 0, '')
        expect(@device.canWriteFITActivities).to.equal false

      it 'returns true if the device can write FIT activities', ->
        @DeviceDescriptionStub.returns """
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
        @device = new Device(@plugin, 0, '')
        expect(@device.canWriteFITActivities).to.equal true
