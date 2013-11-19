{Device}    = require('../src/device')
{XMLParser} = require('../src/utils/xmlparser')

exports.Communicator = class Communicator
  "use strict"

  constructor: ->
    @init()

  init: ->
    @plugin ||= @_initPlugin()
    @_checkIsInstalled()

  busy: (value) ->
    @_busy = value if value?
    @_busy || no

  isLocked: ->
    @plugin.Locked

  unlock: ->
    if @isLocked()
      # TODO: explode if the plugin is locked for now...
      # debugger
      return true

  devices: =>
    unless @busy()
      @busy(yes)
      @unlock()
      deferred = Q.defer()
      deferred.promise.finally => @busy(no)
      @_findDevices(deferred)
      deferred.promise

  _checkIsInstalled: ->
    unless @plugin.Unlock?
      throw new Error("Garmin Communicator plugin not installed")

  _initPlugin: ->
    if @_smellsLikeIE()
      @_createIEPlugin()
    else
      @_createPlugin()

  _findDevices: (deferred) ->
    @plugin.StartFindDevices()
    @_loopUntilFinishedFindingDevices(deferred)

  _loopUntilFinishedFindingDevices: (deferred) ->
    if @plugin.FinishFindDevices()
      deferred.resolve(@_parseDeviceXml())
    else
      setTimeout (=> @_loopUntilFinishedFindingDevices(deferred)), 100

  _parseDeviceXml: ->
    xml = XMLParser.parse(@plugin.DevicesXmlString())
    _(xml.getElementsByTagName("Device")).map (device) =>
      name   = device.getAttribute("DisplayName")
      number = parseInt(device.getAttribute("Number"))
      new Device(@plugin, number, name)

  _smellsLikeIE: ->
    !window.ActiveXObject?

  _createPlugin: ->
    comm_wrapper = document.createElement 'div'
    comm_wrapper.style.width = 0
    comm_wrapper.style.height = 0
    comm = document.createElement 'object'
    comm.id = "GarminNetscapePlugin"
    comm.height = 0
    comm.width  = 0
    comm.setAttribute "type", "application/vnd-garmin.mygarmin"
    comm_wrapper.appendChild comm
    document.body.appendChild comm_wrapper

    comm

  _createIEPlugin: ->
    comm = document.createElement 'object'
    comm.id = "GarminActiveXControl"
    comm.style.width = 0
    comm.style.height = 0
    comm.style.visibility = "hidden"
    comm.height = 0
    comm.width = 0
    comm.setAttribute "classid", "CLSID:099B5A62-DE20-48C6-BF9E-290A9D1D8CB5"
    document.body.appendChild comm

    comm
