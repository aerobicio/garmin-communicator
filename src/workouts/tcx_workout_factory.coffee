{XMLParser}      = require('../utils/xmlparser')
{WorkoutFactory} = require('./workout_factory')
{TcxWorkout}     = require('./tcx_workout')

exports.TcxWorkoutFactory = class TcxWorkoutFactory extends WorkoutFactory
  "use strict"

  produce: (data) ->
    xml = XMLParser.parse(data)
    _.chain(xml.getElementsByTagName("Activity"))
      .map(@_objectForActivityNode)
      .value()

  _objectForActivityNode: (activity) =>
    id   = @_getIdForActivityNode(activity)
    date = @_getFirstLapStartTime(activity)
    new TcxWorkout(@device, id, date)

  _getFirstLapStartTime: (activity) =>
    dateTimeString = activity
      .getElementsByTagName("Lap")[0]
      .getAttribute("StartTime")
    @_parseISODateString(dateTimeString)

  _getIdForActivityNode: (activity) ->
    activity
      .getElementsByTagName("Id")[0]
      .textContent
