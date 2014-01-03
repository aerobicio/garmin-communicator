exports.Plugin = class Plugin
  "use strict"

  constructor: (configuration = {}) ->
    @configuration = configuration
    @el or= @_createPluginEl()

    @checkIsInstalled() unless @configuration.testMode

  softwareVersion: ->
    @el.getPluginVersion()

  _createPluginEl: ->
    if @_smellsLikeIE()
      @_createIEPlugin()
    else
      @_createVanillaPlugin()

  checkIsInstalled: ->
    unless @el.Unlock?
      throw new Error("Garmin Communicator plugin not installed")

  _smellsLikeIE: ->
    window.ActiveXObject?

  _createVanillaPlugin: ->
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
