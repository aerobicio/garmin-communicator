{Communicator} = require('../src/communicator')
{Device}       = require('../src/device')

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

  describe 'Capabilities', ->
    beforeEach ->
      @plugin = {DeviceDescription: -> return}
      @setDeviceInfoStub     = sinon.stub(Device.prototype, '_setDeviceInfo')
      @deviceDescriptionStub = sinon.stub(@plugin, 'DeviceDescription')

    afterEach ->
      @setDeviceInfoStub.restore()
      @deviceDescriptionStub.restore()

    describe '.canReadActivities', ->
      it 'is false by default', ->
        device = new Device(@plugin, 0, '')
        expect(device.canReadActivities).to.equal false

      it 'returns true if the device can read workouts', ->
        @deviceDescriptionStub.returns """
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
        device = new Device(@plugin, 0, '')
        expect(device.canReadActivities).to.equal true

    describe '.canWriteActivities', ->
      it 'is false by default', ->
        device = new Device(@plugin, 0, '')
        expect(device.canWriteActivities).to.equal false

      it 'returns true if the device can write workouts', ->
        @deviceDescriptionStub.returns """
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
        device = new Device(@plugin, 0, '')
        expect(device.canWriteActivities).to.equal true

    describe '.canReadWorkouts', ->
      it 'is false by default', ->
        device = new Device(@plugin, 0, '')
        expect(device.canReadWorkouts).to.equal false

      it 'returns true if the device can read workouts', ->
        @deviceDescriptionStub.returns """
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
        device = new Device(@plugin, 0, '')
        expect(device.canReadWorkouts).to.equal true

    describe '.canWriteWorkouts', ->
      it 'is false by default', ->
        device = new Device(@plugin, 0, '')
        expect(device.canWriteWorkouts).to.equal false

      it 'returns true if the device can write workouts', ->
        @deviceDescriptionStub.returns """
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
        device = new Device(@plugin, 0, '')
        expect(device.canWriteWorkouts).to.equal true

    describe '.canReadCourses', ->
      it 'is false by default', ->
        device = new Device(@plugin, 0, '')
        expect(device.canReadCourses).to.equal false

      it 'returns true if the device can read courses', ->
        @deviceDescriptionStub.returns """
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
        device = new Device(@plugin, 0, '')
        expect(device.canReadCourses).to.equal true

    describe '.canWriteCourses', ->
      it 'is false by default', ->
        device = new Device(@plugin, 0, '')
        expect(device.canWriteCourses).to.equal false

      it 'returns true if the device can write courses', ->
        @deviceDescriptionStub.returns """
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
        device = new Device(@plugin, 0, '')
        expect(device.canWriteCourses).to.equal true

    describe '.canReadGoals', ->
      it 'is false by default', ->
        device = new Device(@plugin, 0, '')
        expect(device.canReadGoals).to.equal false

      it 'returns true if the device can read goals', ->
        @deviceDescriptionStub.returns """
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
        device = new Device(@plugin, 0, '')
        expect(device.canReadGoals).to.equal true

    describe '.canWriteGoals', ->
      it 'is false by default', ->
        device = new Device(@plugin, 0, '')
        expect(device.canWriteGoals).to.equal false

      it 'returns true if the device can write goals', ->
        @deviceDescriptionStub.returns """
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
        device = new Device(@plugin, 0, '')
        expect(device.canWriteGoals).to.equal true

    describe '.canReadProfile', ->
      it 'is false by default', ->
        device = new Device(@plugin, 0, '')
        expect(device.canReadProfile).to.equal false

      it 'returns true if the device can read profiles', ->
        @deviceDescriptionStub.returns """
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
        device = new Device(@plugin, 0, '')
        expect(device.canReadProfile).to.equal true

    describe '.canWriteProfile', ->
      it 'is false by default', ->
        device = new Device(@plugin, 0, '')
        expect(device.canWriteProfile).to.equal false

      it 'returns true if the device can write profiles', ->
        @deviceDescriptionStub.returns """
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
        device = new Device(@plugin, 0, '')
        expect(device.canWriteProfile).to.equal true

    describe '.canReadFITActivities', ->
      it 'is false by default', ->
        device = new Device(@plugin, 0, '')
        expect(device.canReadFITActivities).to.equal false

      it 'returns true if the device can read FIT activities', ->
        @deviceDescriptionStub.returns """
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
        device = new Device(@plugin, 0, '')
        expect(device.canReadFITActivities).to.equal true

    describe '.canWriteFITActivities', ->
      it 'is false by default', ->
        device = new Device(@plugin, 0, '')
        expect(device.canWriteFITActivities).to.equal false

      it 'returns true if the device can write FIT activities', ->
        @deviceDescriptionStub.returns """
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
        device = new Device(@plugin, 0, '')
        expect(device.canWriteFITActivities).to.equal true

  describe 'Data Access', ->
    beforeEach ->
      @setDeviceInfoStub = sinon.stub(Device.prototype, '_setDeviceInfo')
      @plugin = {
        DeviceDescription: -> return,
        busy: -> return
      }
      @deviceDescriptionStub = sinon.stub(@plugin, 'DeviceDescription').returns ""
      @busyStub = sinon.stub(@plugin, 'busy').returns false
      @device = new Device(@plugin, 0, '')

    afterEach ->
      @setDeviceInfoStub.restore()

    describe 'Reading data', ->
      describe '#readActivities', (done) ->
        it 'throws an exception if the device does not support the action', ->
          @device.canReadActivities = false
          expect(=> @device.readActivities()).to.throw Error

        it 'returns a promise of data', ->
          @device.canReadActivities = true
          promise = @device.readActivities()
          expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

      describe '#readWorkouts', (done) ->
        it 'throws an exception if the device does not support the action', ->
          @device.canReadWorkouts = false
          expect(=> @device.readWorkouts()).to.throw Error

        it 'returns a promise of data', ->
          @device.canReadWorkouts = true
          promise = @device.readWorkouts()
          expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

      describe '#readCourses', (done) ->
        it 'throws an exception if the device does not support the action', ->
          @device.canReadCourses = false
          expect(=> @device.readCourses()).to.throw Error

        it 'returns a promise of data', ->
          @device.canReadCourses = true
          promise = @device.readCourses()
          expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

      describe '#readGoals', (done) ->
        it 'throws an exception if the device does not support the action', ->
          @device.canReadGoals = false
          expect(=> @device.readGoals()).to.throw Error

        it 'returns a promise of data', ->
          @device.canReadGoals = true
          promise = @device.readGoals()
          expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

      describe '#readProfile', (done) ->
        it 'throws an exception if the device does not support the action', ->
          @device.canReadProfile = false
          expect(=> @device.readProfile()).to.throw Error

        it 'returns a promise of data', ->
          @device.canReadProfile = true
          promise = @device.readProfile()
          expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

      describe '#readFITActivities', (done) ->
        it 'throws an exception if the device does not support the action', ->
          @device.canReadFITActivities = false
          expect(=> @device.readFITActivities()).to.throw Error

        it 'returns a promise of data', ->
          @device.canReadFITActivities = true
          promise = @device.readFITActivities()
          expect(promise? and _(promise).isObject() and promise.isFulfilled?).to.equal true

    describe 'Writing data', ->
      describe '#writeActivities', (done) ->
        it 'is not implemented and throws an exception', ->
          expect(=> @device.writeActivities()).to.throw Error

      describe '#writeWorkouts', (done) ->
        it 'is not implemented and throws an exception', ->
          expect(=> @device.writeWorkouts()).to.throw Error

      describe '#writeCourses', (done) ->
        it 'is not implemented and throws an exception', ->
          expect(=> @device.writeCourses()).to.throw Error

      describe '#writeGoals', (done) ->
        it 'is not implemented and throws an exception', ->
          expect(=> @device.writeGoals()).to.throw Error

      describe '#writeProfile', (done) ->
        it 'is not implemented and throws an exception', ->
          expect(=> @device.writeProfile()).to.throw Error

      describe '#writeFITActivities', (done) ->
        it 'is not implemented and throws an exception', ->
          expect(=> @device.writeFITActivities()).to.throw Error
