{Communicator} = require('./communicator')
{Reader}       = require('./device/reader')
{XMLParser}    = require('./utils/xmlparser')

exports.Device = class Device
  "use strict"

  # TRANSFER_MODES:
  #   read:  "OutputFromUnit"
  #   write: "InputToUnit"
  #   both:  "InputOutput"

  ACTIONS:
    Activities:     ['FitnessHistory',        'FitnessDirectory']
    Workouts:       ['FitnessWorkouts',       'FitnessData']
    Courses:        ['FitnessCourses',        'FitnessData']
    Goals:          ['FitnessActivityGoals',  'FitnessData']
    Profile:        ['FitnessUserProfile',    'FitnessData']
    FITActivities:  ['FIT_TYPE_4',            'FITDirectory']

  constructor: (@number, @name) ->
    @communicator = Communicator.get()
    @deviceDescriptionXml = @_getDeviceDescriptionXml()
    @_setDeviceInfo()
    @_setDeviceCapabilities()
    @_createDeviceAccessors()

  activities: ->
    if @canReadFITActivities then @readFITActivities() else @readActivities()

  _setDeviceCapabilities: ->
    _.each @ACTIONS, (data, type) ->
      @["canRead#{type}"]  = @_canXY('Output', data[0])
      @["canWrite#{type}"] = @_canXY('Input', data[0])
    , @

  _createDeviceAccessors: ->
    _.each @ACTIONS, (data, type) ->
      @["read#{type}"]  = @_reader(type, data[0], data[1])
      @["write#{type}"] = @_writer()
    , @

  _reader: (type, dataType, pluginMethod) ->
    ->
      unless @["canRead#{type}"]
        throw new Error("read#{type} is not supported on this device")
      reader = new Reader(@, dataType, pluginMethod)
      reader.perform()

  _writer: ->
    -> throw new Error("Not implemented")

  _canXY: (method, dataTypeName) ->
    transferDirection = @_getDataTypeNodeForDataTypeName(dataTypeName)
      ?.getElementsByTagName("File")[0]
      ?.getElementsByTagName("TransferDirection")[0].textContent
    # trasferDirection can be any one of the following:
    # - InputToUnit:    writing files to the device
    # - OutputFromUnit: reading files from the device
    # - InputOutput:    reading and writing files from/to the device
    # we use a regex to test if the required method is contained in the
    # device’s TransferDirection node.
    transferDirection? and new RegExp(method).test(transferDirection)

  _getDataTypeNodeForDataTypeName: (name) ->
    dataTypesXml = @_getDeviceDataTypesXml()
    if dataTypesXml
      _.filter(dataTypesXml, (node) ->
        name == node.getElementsByTagName("Name")[0].textContent
      )[0]

  _getDeviceDataTypesXml: ->
    @_deviceDataTypes ||= @deviceDescriptionXml
      ?.getElementsByTagName("MassStorageMode")[0]
      ?.getElementsByTagName("DataType")

  _setDeviceInfo: ->
    @id              = @_deviceId()
    @name            = @_deviceDisplayName()
    @partNumber      = @_devicePartNumber()
    @softwareVersion = @_softwareVersion()

  _getDeviceDescriptionXml: ->
    xml = @communicator.invoke('DeviceDescription', @number)
    XMLParser.parse(xml)

  _deviceId: ->
    @deviceDescriptionXml.getElementsByTagName("Id")[0].textContent

  _deviceDisplayName: ->
    model = @deviceDescriptionXml.getElementsByTagName("Model")[0]
    if model.getElementsByTagName("DisplayName").length
      model.getElementsByTagName("DisplayName")[0].textContent
    else
      model.getElementsByTagName("Description")[0].textContent

  _devicePartNumber: ->
    @deviceDescriptionXml
      .getElementsByTagName("Model")[0]
      .getElementsByTagName("PartNumber")[0].textContent

  _softwareVersion: ->
    @deviceDescriptionXml
      .getElementsByTagName("Model")[0]
      .getElementsByTagName("SoftwareVersion")[0].textContent
