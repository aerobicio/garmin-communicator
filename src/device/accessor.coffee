exports.Accessor = class Accessor
  "use strict"

  constructor: (pluginDelegate, dataType, pluginMethod) ->
    @pluginDelegate = pluginDelegate
    @dataType       = dataType
    @pluginMethod   = pluginMethod

  perform: ->
    @deferred = Q.defer()
    throw new Error("Plugin is busy") if @pluginDelegate.busy()
    @pluginDelegate.busy(yes)
    # fn = @_pluginCallableForAction()
    # fn(@device.number, @dataType)

  _pluginCallableForAction: ->
    # returns a function of the form: 'StartReadFitnessDirectory'
    @pluginDelegate["Start#{@action}#{@pluginMethod}"]

