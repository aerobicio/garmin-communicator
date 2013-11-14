exports.XMLParser = class XMLParser
  "use strict"

  constructor: (xml) ->
    @parser = @_getParser()

  parse: ->
    @parser xml

  _getParser: ->
    if window.DOMParser?
      (xml) -> new window.DOMParser().parseFromString(xml, "text/xml")
    else if window.ActiveXObject? and window.ActiveXObject("Microsoft.XMLDOM")
      (xml) ->
        xmlDoc = new window.ActiveXObject("Microsoft.XMLDOM")
        xmlDoc.async = "false"
        xmlDoc.loadXML xml
    else
      throw new Error "No XML parser found, can’t parse XML"
