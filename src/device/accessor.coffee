{XMLParser} = require('../utils/xmlparser')

exports.Accessor = class Accessor
  "use strict"

  PERCENT_REGEX: /^[0-9]+%/
  STATUS_CODES:
    idle:     0
    working:  1
    waiting:  2
    finished: 3
    error:    -1

  constructor: (communicator, device, dataType, pluginMethod) ->
    @communicator = communicator
    @device       = device
    @dataType     = dataType
    @pluginMethod = pluginMethod

    @pluginAction = "#{@action}#{@pluginMethod}"

  perform: ->
    @deferred = Q.defer()
    throw new Error("Plugin is busy") if @communicator.busy()
    @communicator.invoke(@_startPluginAction(), @device.number, @dataType)
    @_checkFinished(@deferred)

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
      else throw new Error("Unexpected Velociraptor.")

  _onWorking: (deferred) ->
    deferred.notify(@_progress())
    setTimeout (=> @_checkFinished(deferred)), 100

  _onFinished: (deferred) ->
    deferred.notify(percent: 100)
    deferred.resolve(@_loadDataFromDirectory())

  _onWaiting: (deferred) ->
    setTimeout (=> @_checkFinished(deferred)), 500

  _onIdle: (deferred) ->
    deferred.reject()

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

  _loadDataFromDirectory: ->
    switch @pluginMethod
      when 'FitnessDirectory' then @communicator.read("TcdXml")
      when 'FITDirectory'     then @communicator.read("DirectoryListingXml")
