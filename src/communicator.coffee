{Plugin}    = require('../src/plugin')
{XMLParser} = require('../src/utils/xmlparser')

exports.Communicator = class Communicator
  "use strict"

  _configuration = null
  _instance = null

  @get: (configuration = {}) ->
    _configuration ||= configuration
    _instance ||= new PrivateCommunicator(_configuration)

  @destroy: ->
    _instance = null
    return

  class PrivateCommunicator
    pluginIsInstalled: null

    constructor: (configuration) ->
      @configuration     = configuration
      @plugin            = new Plugin()
      @pluginIsInstalled = @plugin.pluginIsInstalled()
      @pluginProxy       = @plugin.el

    invoke: (name, args...) ->
      fn = @pluginProxy[name]

      if fn? and typeof fn is 'function'
        fn.apply(@pluginProxy, args)
      else
        throw new Error("'#{name}' function does not exist!")

    write: (name, data) ->
      if @pluginProxy.hasOwnProperty(name)
        @pluginProxy[name] = data

    read: (name) ->
      if @pluginProxy.hasOwnProperty(name)
        @pluginProxy[name]

    busy: (value) ->
      @_busy = value if value?
      @_busy or no

    isLocked: ->
      @pluginProxy.Locked

    unlock: (unlockCodes) ->
      if @isLocked()
        unlocked = false
        _(unlockCodes).map (unlockKey, domain) =>
          unlocked ||= @invoke('Unlock', domain, unlockKey)
        unlocked

    devices: =>
      unless @busy()
        @busy(yes)
        @unlock()
        deferred = Q.defer()
        deferred.promise.finally => @busy(no)
        @_findDevices(deferred)
        deferred.promise

    _findDevices: (deferred) ->
      @invoke('StartFindDevices')
      @_loopUntilFinishedFindingDevices(deferred)

    _loopUntilFinishedFindingDevices: (deferred) ->
      if @invoke('FinishFindDevices')
        deferred.resolve(@_parseDeviceXml())
      else
        setTimeout (=> @_loopUntilFinishedFindingDevices(deferred)), 100

    _parseDeviceXml: ->
      # this sucks, but avoids a weird circular dependancy issue that exists
      {Device} = require('../src/device')

      xml = XMLParser.parse(@invoke('DevicesXmlString'))
      _(xml.getElementsByTagName("Device")).map (device) =>
        name   = device.getAttribute("DisplayName")
        number = parseInt(device.getAttribute("Number"), 10)
        new Device(number, name)
