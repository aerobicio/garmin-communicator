{Communicator} = require('../../src/communicator')
{XMLParser}    = require('../utils/xmlparser')

exports.Accessor = class Accessor
  "use strict"

  PERCENT_REGEX: /^[0-9]+%/
  STATUS_CODES:
    idle:     0
    working:  1
    waiting:  2
    finished: 3

  constructor: (@device, @dataType, @pluginMethod) ->
    @communicator = Communicator.get()
    @pluginAction = "#{@ACTION}#{@pluginMethod}"

  perform: ->
    @deferred = Q.defer()
    throw new Error("Plugin is busy") if @communicator.busy()
    @communicator.invoke(@_startPluginAction(), @device.number, @dataType)
    @_checkFinished(@deferred)
    @deferred.promise

  _startPluginAction: ->
    "Start#{@pluginAction}"

  _finishPluginAction: ->
    "Finish#{@pluginAction}"

  _checkFinished: (deferred) =>
    switch @communicator.invoke(@_finishPluginAction())
      when @STATUS_CODES.working  then @_onWorking(deferred)
      when @STATUS_CODES.finished then @_onFinished(deferred)
      when @STATUS_CODES.waiting  then @_onWaiting(deferred)
      when @STATUS_CODES.idle     then @_onIdle(deferred)
      else
        throw new Error("Unexpected Velociraptor.")

  _onWorking: (deferred) ->
    deferred.notify(@_progress())
    setTimeout (=> @_checkFinished(deferred)), 100

  _onWaiting: (deferred) ->
    setTimeout (=> @_checkFinished(deferred)), 500

  _onIdle: (deferred) ->
    deferred.reject()

  _onFinished: ->
    throw new Error("Not Implemented")

  _progress: ->
    progress    = {content: [], percent: 0}
    progressXml = @_getProgressXml().getElementsByTagName("ProgressWidget")[0]

    progress.message = progressXml.getElementsByTagName("Title")[0]?.textContent
    _.each progressXml.getElementsByTagName("Text"), (node) =>
      if node.textContent.match(@PERCENT_REGEX)
        progress.percent = parseInt(node.textContent, 10)
      else
        progress.content.push(node.textContent)
    progress

  _getProgressXml: ->
    xml = @communicator.read("ProgressXml")
    XMLParser.parse(xml)
