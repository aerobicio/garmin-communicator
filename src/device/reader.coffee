{Accessor} = require('./accessor')

exports.Reader = class Reader extends Accessor
  "use strict"

  action: 'Read'

  perform: ->
    @_clearDeviceXmlBuffers()
    super
    @deferred.promise

  _clearDeviceXmlBuffers: ->
    @communicator.write("TcdXml", "")
    @communicator.write("DirectoryListingXml", "")

