{Device}    = require('../src/device')
{Plugin}    = require('../src/plugin')
{XMLParser} = require('../src/utils/xmlparser')

exports.Communicator = class Communicator
  "use strict"

  constructor: ->
    @plugin      = new Plugin()
    @pluginProxy = @plugin.el

  busy: (value) ->
    @_busy = value if value?
    @_busy || no

  isLocked: ->
    @pluginProxy.Locked

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

  _findDevices: (deferred) ->
    @pluginProxy.StartFindDevices()
    @_loopUntilFinishedFindingDevices(deferred)

  _loopUntilFinishedFindingDevices: (deferred) ->
    if @pluginProxy.FinishFindDevices()
      deferred.resolve(@_parseDeviceXml())
    else
      setTimeout (=> @_loopUntilFinishedFindingDevices(deferred)), 100

  _parseDeviceXml: ->
    xml = XMLParser.parse(@pluginProxy.DevicesXmlString())
    _(xml.getElementsByTagName("Device")).map (device) =>
      name   = device.getAttribute("DisplayName")
      number = parseInt(device.getAttribute("Number"))
      new Device(@, number, name)
