{Device} = require('../src/Device')

exports.Communicator = class Communicator
  "use strict"

  constructor: ->
    @isBusy = no
    @plugin = null

    @initCommunicator()

  initCommunicator: ->
    return @plugin if @plugin

    if @_smellsLikeIE() @_createIEPlugin() else @_createPlugin()

  isLocked: ->
    @plugin.Locked

  unlock: ->
    # TODO: explode if the plugin is locked for now...
    debugger if @isLocked()

  findDevices: ->
    @unlock() if @isLocked()
    promise = new Deferred
    # @plugin.StartFindDevices()
    # @_loopUntilFinishedFindingDevices(promise)
    promise

  _loopUntilFinishedFindingDevices: (promise) ->
    if @plugin.FinishFindDevices()
      data = new XMLParser(@plugin.DevicesXmlString()).parse
      promise.call(data)
      console.log data
    else
      setTimeout @_loopUntilFinishedFindingDevices(promise), 100

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

    @plugin = comm

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

    @plugin = comm
