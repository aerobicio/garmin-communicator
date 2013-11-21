{Communicator} = require('../src/communicator')

exports.Garmin = class Garmin
  @defaultUnlockCodes: [
    "file:///", "cb1492ae040612408d87cc53e3f7ff3c",
    "http://localhost", "45517b532362fc3149e4211ade14c9b2",
    "http://127.0.0.1", "40cd4860f7988c53b15b8491693de133"
  ]

  constructor: (options) ->
    # options = _(options).defaults
    #   derp: ""

    # @communicator = new Communicator
    # @communicator.unlock()
