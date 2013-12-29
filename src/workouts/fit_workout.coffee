{Communicator} = require('../../src/communicator')

exports.FitWorkout = class FitWorkout
  "use strict"

  constructor: (device, id, type, date, path) ->
    @id = id
    @device = device
    @type = type
    @date = date
    @path = path
    @communicator = Communicator.get()

  getData: ->
    deferred = Q.defer()
    deferred.resolve(@_getBinaryFile())
    deferred.promise

  _getBinaryFile: ->
    @communicator.invoke("GetBinaryFile", @device.number, @path, false)
