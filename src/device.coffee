{XMLParser} = require('../src/utils/XMLParser')

exports.Device = class Device
  "use strict"

  FitnessTypes:
    Activities:     ['FitnessHistory', 'FitnessDirectory']
    Workouts:       ['FitnessWorkouts', 'FitnessData']
    Courses:        ['FitnessCourses', 'FitnessData']
    Goals:          ['FitnessActivityGoals', 'FitnessData']
    Profile:        ['FitnessUserProfile', 'FitnessData']
    FITActivities:  ['FIT_TYPE_4', 'FITDirectory']

  constructor: (@pluginDelegate, @number, @name) ->
    @init()
    @createDeviceCapabilityGetters()

  init: ->
    @_getDeviceInfoXml()
    @_getDeviceInfo()

  createDeviceCapabilityGetters: ->
    _.each @FitnessTypes, (data, type) ->
      @["canRead#{type}"]  = @_canXY('Output', data[0])
      @["canWrite#{type}"] = @_canXY('Input', data[0])
    , @

  _canXY: (action, dataTypeName) ->
    ->
      transferDirection = @_getDataTypeNodeForDataTypeName(dataTypeName)
        ?.getElementsByTagName("File")[0]
        ?.getElementsByTagName("TransferDirection")[0].textContent
      # trasferDirection can be any one of the following:
      # - InputToUnit:    writing files to the device
      # - OutputFromUnit: reading files from the device
      # - InputOutput:    reading and writing files from/to the device
      # we use a regex to test if the required action is contained in the
      # device’s TransferDirection node.
      new RegExp(action).test(transferDirection)

  _getDataTypeNodeForDataTypeName: (name) ->
    dataTypesXml = @_getDeviceDataTypesXml()
    if dataTypesXml
      _.filter(dataTypesXml, (node) ->
        name == node.getElementsByTagName("Name")[0].textContent
      )[0]

  _getDeviceDataTypesXml: ->
    @_deviceDataTypes ||= @deviceInfoXml
      ?.getElementsByTagName("MassStorageMode")[0]
      ?.getElementsByTagName("DataType")

  _getDeviceInfo: ->
    @id              = @_deviceId()
    @name            = @_deviceDisplayName()
    @partNumber      = @_devicePartNumber()
    @softwareVersion = @_softwareVersion()

  _getDeviceInfoXml: ->
    @deviceInfoXml = XMLParser.parse(@pluginDelegate.DeviceDescription(@number))

  _deviceId: ->
    @deviceInfoXml.getElementsByTagName("Id")[0].textContent

  _deviceDisplayName: ->
    model = @deviceInfoXml.getElementsByTagName("Model")[0]
    if model.getElementsByTagName("DisplayName").length
      model.getElementsByTagName("DisplayName")[0].textContent
    else
      model.getElementsByTagName("Description")[0].textContent

  _devicePartNumber: ->
    @deviceInfoXml
      .getElementsByTagName("Model")[0]
      .getElementsByTagName("PartNumber")[0].textContent

  _softwareVersion: ->
    @deviceInfoXml
      .getElementsByTagName("Model")[0]
      .getElementsByTagName("SoftwareVersion")[0].textContent
