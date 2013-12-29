exports.TcxWorkout = class TcxWorkout
  "use strict"

  constructor: (device, id, date) ->
    {Reader} = require('../device/reader')

    @device = device
    @id = id
    @date = date
    @detailReader = new Reader(@device, "FitnessHistory", "FitnessDetail")

  getData: ->
    @detailReader.perform(@id)
