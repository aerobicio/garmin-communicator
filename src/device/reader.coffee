{Communicator}      = require('../communicator')
{Accessor}          = require('./accessor')
{FitWorkoutFactory} = require('../workouts/fit_workout_factory')
{TcxWorkoutFactory} = require('../workouts/tcx_workout_factory')

exports.Reader = class Reader extends Accessor
  "use strict"

  ACTION: "Read"

  perform: ->
    @clearDeviceXmlBuffers()
    super
    @deferred.promise

  clearDeviceXmlBuffers: ->
    @communicator.write("TcdXml", "")
    @communicator.write("DirectoryListingXml", "")

  _onFinished: (deferred) ->
    deferred.notify(percent: 100)
    deferred.resolve(@handleFinishedReading())

  handleFinishedReading: ->
    switch @pluginMethod
      when 'FITDirectory'     then @handleReadFITDirectory()
      when 'FitnessDirectory' then @handleReadFitnessDirectory()
      when 'FitnessDetail'    then @handleReadFitnessDetail()

  handleReadFITDirectory: ->
    data = @communicator.read("DirectoryListingXml")
    new FitWorkoutFactory(@device).produce(data)

  handleReadFitnessDirectory: ->
    data = @communicator.read("TcdXml")
    new TcxWorkoutFactory(@device).produce(data)

  handleReadFitnessDetail: ->
    @communicator.read("TcdXml")
