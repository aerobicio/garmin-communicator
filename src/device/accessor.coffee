exports.Accessor = class Accessor
  "use strict"

  constructor: (communicator, device, dataType, pluginMethod) ->
    @communicator = communicator
    @device       = device
    @dataType     = dataType
    @pluginMethod = pluginMethod

  perform: ->
    @deferred = Q.defer()
    throw new Error("Plugin is busy") if @communicator.busy()
    @communicator.invoke(@_callableNameForAction(), @device.number, @dataType)

  _callableNameForAction: ->
    # returns a function of the form: 'StartReadFitnessDirectory'
    "Start#{@action}#{@pluginMethod}"

