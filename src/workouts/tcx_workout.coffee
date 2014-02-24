exports.TcxWorkout = class TcxWorkout
  "use strict"

  constructor: (@device, @id, @date) ->
    {Reader} = require('../device/reader')

    @detailReader = new Reader(
      @device.number,
      "FitnessHistory",
      "FitnessDetail"
    )

  getData: ->
    @detailReader.perform(@id)
