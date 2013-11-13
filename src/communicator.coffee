exports.Communicator = class Communicator
  "use strict"

  constructor: ->
    @communicator = null

    @initCommunicator()

  initCommunicator: ->
    return @communicator if @communicator

    @communicator = if window.ActiveXObject
      @_createIeCommunicator()
    else
      @_createCommunicator()

  unlock: ->
    debugger

  _createCommunicator: ->
    comm_wrapper = document.createElement 'div'
    comm_wrapper.style  = "width: 0; height: 0;"
    comm = document.createElement 'object'
    comm.height = 0
    comm.width  = 0
    comm.setAttribute "type", "application/vnd-garmin.mygarmin"
    # comm.innerHTML "&#160;"
    comm_wrapper.appendChild comm
    document.body.appendChild comm_wrapper

    comm

  _createIePlugin: ->
    comm = document.createElement 'object'
    comm.id = "GarminActiveXControl"
    comm.style = "width: 0; height: 0; visibility: hidden;"
    comm.height = 0
    comm.width = 0
    comm.setAttribute "classid", "CLSID:099B5A62-DE20-48C6-BF9E-290A9D1D8CB5"
    document.body.appendChild comm

    comm
