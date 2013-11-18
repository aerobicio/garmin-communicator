{Accessor} = require('./accessor')

exports.Reader = class Reader extends Accessor
  "use strict"

  action: 'Read'

  perform: ->
    super
    @deferred.promise
