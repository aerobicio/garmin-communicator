{TcxWorkoutFactory} = require('../../src/workouts/tcx_workout_factory')

describe 'TcxWorkoutFactory', ->
  beforeEach ->
    @device = sinon.stub()
    @class = new TcxWorkoutFactory(@device)
    @data = """
      <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
      <TrainingCenterDatabase>
        <Activities>
          <Activity Sport="Running">
            <Id>2013-12-25T08:35:56Z</Id>
            <Lap StartTime="2013-12-25T08:35:56Z">
              <TotalTimeSeconds>346.3900000</TotalTimeSeconds>
              <DistanceMeters>1000.0000000</DistanceMeters>
              <Calories>64</Calories>
              <Intensity>Active</Intensity>
              <TriggerMethod>Distance</TriggerMethod>
            </Lap>
          </Activity>
          <Activity Sport="Running">
            <Id>2013-12-15T07:12:31Z</Id>
            <Lap StartTime="2013-12-15T07:12:31Z">
              <TotalTimeSeconds>268.9800000</TotalTimeSeconds>
              <DistanceMeters>1000.0000000</DistanceMeters>
              <Calories>65</Calories>
              <Intensity>Active</Intensity>
              <TriggerMethod>Distance</TriggerMethod>
            </Lap>
            <Lap StartTime="2013-12-15T07:17:00Z">
              <TotalTimeSeconds>332.5600000</TotalTimeSeconds>
              <DistanceMeters>1000.0000000</DistanceMeters>
              <Calories>70</Calories>
              <Intensity>Active</Intensity>
              <TriggerMethod>Distance</TriggerMethod>
            </Lap>
          </Activity>
        </Activities>
      </TrainingCenterDatabase>
    """

  describe "#produce", ->
    it "creates an array of TcxWorkout from ActivityNodes", ->
      tcxFiles = @class.produce(@data)
      expect(tcxFiles.length).to.equal 2
      expect(tcxFiles[0].id).to.equal "2013-12-25T08:35:56Z"
      expect(tcxFiles[0].date.toString()).to.equal new Date("Wed Dec 25 2013 08:35:56").toString()
      expect(tcxFiles[1].id).to.equal "2013-12-15T07:12:31Z"
      expect(tcxFiles[1].date.toString()).to.equal new Date("Sun Dec 15 2013 07:12:31").toString()

  describe "#_getFirstLapStartTime", ->
    it "returns the creation time as a date object", ->
      @_getFirstLapStartTimeSpy = sinon.spy(@class, '_getFirstLapStartTime')
      @class.produce(@data)
      date = new Date("Wed Dec 25 2013 08:35:56").toString()
      expect(@_getFirstLapStartTimeSpy.returnValues[0].toString()).to.include date
      @_getFirstLapStartTimeSpy.restore()

  describe "#_getIdForActivityNode", ->
    it "returns the id of the activity", ->
      @_getIdForActivityNodeSpy = sinon.spy(@class, '_getIdForActivityNode')
      @class.produce(@data)
      expect(@_getIdForActivityNodeSpy.calledTwice).to.be.true
      expect(@_getIdForActivityNodeSpy.returnValues).to.include "2013-12-25T08:35:56Z"
      @_getIdForActivityNodeSpy.restore()
