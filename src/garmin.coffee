{Communicator} = require('./communicator')

window.Garmin = class Garmin
  "use strict"

  DEFAULT_UNLOCK_CODES:
    "file:///":         "cb1492ae040612408d87cc53e3f7ff3c"
    "http://localhost": "45517b532362fc3149e4211ade14c9b2"
    "http://127.0.0.1": "40cd4860f7988c53b15b8491693de133"

  constructor: (options = {}) ->
    @configuration = _(options).defaults
      unlockCodes: @mergeUnlockCodes(options.unlockCodes)
      testMode: false

    @communicator = Communicator.get(@configuration)
    @unlock()

  mergeUnlockCodes: (unlockCodes = {}) ->
    _(@DEFAULT_UNLOCK_CODES).defaults(unlockCodes)

  isInstalled: ->
    @isInstalled = @communicator.pluginIsInstalled || @configuration.testMode

  unlock: ->
    unless @configuration.testMode
      @communicator.unlock(@configuration.unlockCodes)

  devices: ->
    @communicator.devices()
