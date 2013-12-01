{Communicator} = require('../../src/communicator')
{Accessor}     = require('./accessor')
{XMLParser}    = require('../utils/xmlparser')
{FitFile}      = require('../../src/fitfile')

exports.Reader = class Reader extends Accessor
  "use strict"

  ACTION: "Read"
  FITFILE_TYPES:
    activities: 4
    goals:      11
    locations:  8
    monitoring: 9
    profiles:   2
    schedules:  7
    sports:     3
    totals:     10

  perform: ->
    @_clearDeviceXmlBuffers()
    super
    @deferred.promise

  _clearDeviceXmlBuffers: ->
    Communicator.get().write("TcdXml", "")
    Communicator.get().write("DirectoryListingXml", "")

  _onFinished: (deferred) ->
    deferred.notify(percent: 100)
    deferred.resolve(@_loadDataFromDirectory())

  _loadDataFromDirectory: ->
    switch @pluginMethod
      when 'FitnessDirectory' then Communicator.get().read("TcdXml")
      when 'FITDirectory'     then @_parseFitDirectory()

  _parseFitDirectory: ->
    xml = XMLParser.parse(@_getFitDirectoryXml())

    _.chain(xml.getElementsByTagName("File"))
      .filter(@_filterFileXmlType)
      .map(@_fitObjectForFile)
      .value()

  _fitObjectForFile: (file) =>
    id   = @_getIdForFile(file)
    type = @_getTypeDescriptionForFile(file)
    date = @_getDateObjectForFile(file)
    path = @_getPathForFile(file)
    new FitFile(@device, id, type, date, path)

  _filterFileXmlType: (file) =>
    @_getTypeDescriptionForFile(file) is @FITFILE_TYPES.activities

  _getFitDirectoryXml: ->
    Communicator.get().read("DirectoryListingXml")

  _getIdForFile: (fileXml) ->
    fileXml
      .getElementsByTagName("FitId")[0]
      .getElementsByTagName("Id")[0]
      .textContent

  _getDateObjectForFile: (fileXml) ->
    # http://stackoverflow.com/questions/14238261/convert-yyyy-mm-ddthhmmss-fffz-to-datetime-in-javascript-manually
    @REPLACE_DATE_DASHES_REGEX ||= /-/g
    @REPLACE_DATE_TZ_REGEX     ||= /[TZ]/g
    formattedDateString = fileXml.getElementsByTagName("CreationTime")[0]
      .textContent
      .replace(@REPLACE_DATE_DASHES_REGEX, "/")
      .replace(@REPLACE_DATE_TZ_REGEX, " ")
    new Date(formattedDateString)

  _getTypeDescriptionForFile: (fileXml) ->
    parseInt fileXml
      .getElementsByTagName("FitId")[0]
      .getElementsByTagName("FileType")[0]
      .textContent

  _getPathForFile: (file) ->
    file.getAttribute("Path")

