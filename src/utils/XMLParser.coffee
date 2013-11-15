exports.XMLParser = class XMLParser
  "use strict"

  @parse: (xml) ->
    @_getParser() unless @_parser
    @_parser(xml)

  @_getParser: ->
    @_parser = if window.DOMParser?
      (xml) -> new window.DOMParser().parseFromString(xml, "text/xml")
    else if window.ActiveXObject? and window.ActiveXObject("Microsoft.XMLDOM")
      (xml) ->
        xmlDoc = new window.ActiveXObject("Microsoft.XMLDOM")
        xmlDoc.async = "false"
        xmlDoc.loadXML(xml)
    else
      throw new Error "No XML parser found, can’t parse XML"
