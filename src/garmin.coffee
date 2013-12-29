{Communicator} = require('../src/communicator')

window.Garmin = class Garmin
  "use strict"

  DEFAULT_UNLOCK_CODES:
    "file:///":         "cb1492ae040612408d87cc53e3f7ff3c"
    "http://localhost": "45517b532362fc3149e4211ade14c9b2"
    "http://127.0.0.1": "40cd4860f7988c53b15b8491693de133"

  constructor: (options = {}) ->
    @communicator = Communicator.get()
    @options = _(options).defaults
      unlock_codes: @mergeUnlockCodes(options.unlock_codes)
    @unlock()

  mergeUnlockCodes: (unlockCodes = {}) ->
    _(@DEFAULT_UNLOCK_CODES).defaults(unlockCodes)

  unlock: ->
    @communicator.unlock(@options.unlock_codes)

  devices: ->
    @communicator.devices()
