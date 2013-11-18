exports.Accessor = class Accessor
  "use strict"

  constructor: (@pluginDelegate, @dataType, @pluginMethod) ->
    @init?()

  perform: ->
    @deferred = Q.defer()
    throw new Error("Plugin is busy") if @pluginDelegate.busy()
    @pluginDelegate.busy(yes)

  _pluginActionCallable: ->
    # returns a function of the form: 'StartReadFitnessDirectory'
    @pluginDelegate["Start#{@::action}#{@pluginMethod}"]

