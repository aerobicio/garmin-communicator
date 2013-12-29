exports.TcxFile = class TcxFile
  "use strict"

  constructor: (xml) ->
    @data = xml

  getData: ->
    deferred = Q.defer()
    deferred.resolve(@data)
    deferred.promise
