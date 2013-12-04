{Communicator} = require('../src/communicator')

exports.FitFile = class FitFile
  "use strict"

  UUENCODE_HEADER_REGEX: /^.+\r*\n/
  UUENCODE_INVALID_CHARS_REGEX: /[^A-Za-z0-9\+\/\=]/g

  constructor: (@device, @id, @type, @data, @path) ->
    @communicator = Communicator.get()

  getData: ->
    deferred = Q.defer()
    deferred.resolve(@_getBinaryFile())
    deferred.promise

  _getBinaryFile: ->
    @communicator.invoke("GetBinaryFile", @device.number, @path, false)
