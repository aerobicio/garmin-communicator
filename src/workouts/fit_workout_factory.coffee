{XMLParser}      = require('../utils/xmlparser')
{WorkoutFactory} = require('./workout_factory')
{FitWorkout}     = require('./fit_workout')

exports.FitWorkoutFactory = class FitWorkoutFactory extends WorkoutFactory
  "use strict"

  produce: (data) ->
    xml = XMLParser.parse(data)
    _.chain(xml.getElementsByTagName("File"))
      .filter(@_filterFitFileXmlType)
      .map(@_objectForFileNode)
      .value()

  _objectForFileNode: (file) =>
    id   = @_getIdForFileNode(file)
    type = @_getFileTypeForFileNode(file)
    date = @_getCreationTimeFileNode(file)
    path = @_getPathForFileNode(file)

    new FitWorkout(@device, id, type, date, path)

  _getCreationTimeFileNode: (file) ->
    dateTimeString = file
      .getElementsByTagName("CreationTime")[0]
      .textContent
    @_parseISODateString(dateTimeString)

  _filterFitFileXmlType: (file) =>
    @_getFileTypeForFileNode(file) is @FITFILE_TYPES.activities

  _getIdForFileNode: (fileXml) ->
    parseInt(fileXml
      .getElementsByTagName("FitId")[0]
      .getElementsByTagName("Id")[0]
      .textContent
    , 10)

  _getFileTypeForFileNode: (fileXml) ->
    parseInt(fileXml
      .getElementsByTagName("FitId")[0]
      .getElementsByTagName("FileType")[0]
      .textContent
    , 10)

  _getPathForFileNode: (file) ->
    file.getAttribute("Path")
