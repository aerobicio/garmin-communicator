{FitWorkoutFactory} = require('../../src/workouts/fit_workout_factory')

describe 'FitWorkoutFactory', ->
  beforeEach ->
    @device = sinon.stub()
    @class = new FitWorkoutFactory(@device)
    @data = """
      <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
      <DirectoryListing>
        <File IsDirectory="false" Path="Monitoring/1-1499-ANTFS-15-0.FIT">
          <CreationTime>2013-11-17T07:14:28Z</CreationTime>
          <FitId>
            <FileType>15</FileType>
            <Manufacturer>1</Manufacturer>
            <Product>1499</Product>
            <SerialNumber>3856053743</SerialNumber>
            <FileNumber>0</FileNumber>
          </FitId>
        </File>
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

  describe "#produce", ->
    it "creates an array of FitWorkouts from suitable FileNodes", ->
      fitFiles = @class.produce(@data)
      expect(fitFiles.length).to.equal 1
      expect(fitFiles[0].id).to.equal 731412310
      expect(fitFiles[0].type).to.equal 4
      expect(fitFiles[0].date.toString()).to.equal new Date("Tue Mar 05 2013 10:05:10 GMT+1100 (EST)").toString()
      expect(fitFiles[0].path).to.equal "Activities/20130305-210510-1-1499-ANTFS-4-0.FIT"

  describe "#_getCreationTimeFileNode", ->
    it "returns the creation time as a date object", ->
      @_getCreationTimeFileNodeSpy = sinon.spy(@class, '_getCreationTimeFileNode')
      @class.produce(@data)
      date = new Date("Tue Mar 05 2013 10:05:10 GMT+1100 (EST)").toString()
      expect(@_getCreationTimeFileNodeSpy.returnValues[0].toString()).to.include date
      @_getCreationTimeFileNodeSpy.restore()

  describe "#_getIdForFileNode", ->
    it "returns the id of the file", ->
      @_getIdForFileNodeSpy = sinon.spy(@class, '_getIdForFileNode')
      @class.produce(@data)
      expect(@_getIdForFileNodeSpy.returnValues.length).to.equal 1
      expect(@_getIdForFileNodeSpy.returnValues).to.include 731412310
      @_getIdForFileNodeSpy.restore()

  describe "#_getFileTypeForFileNode", ->
    it "returns the file type as an integer", ->
      @_getFileTypeForFileNodeSpy = sinon.spy(@class, '_getFileTypeForFileNode')
      @class.produce(@data)
      expect(@_getFileTypeForFileNodeSpy.returnValues).to.include 4
      @_getFileTypeForFileNodeSpy.restore()

  describe "#_getPathForFileNode", ->
    it "returns the path for the file", ->
      @_getPathForFileNodeSpy = sinon.spy(@class, '_getPathForFileNode')
      @class.produce(@data)
      expect(@_getPathForFileNodeSpy.returnValues.length).to.equal 1
      expect(@_getPathForFileNodeSpy.returnValues).to.include "Activities/20130305-210510-1-1499-ANTFS-4-0.FIT"
      @_getPathForFileNodeSpy.restore()
