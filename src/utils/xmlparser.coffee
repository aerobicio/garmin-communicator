exports.XMLParser = class XMLParser
  "use strict"

  @parse: (xml) ->
    @_getParser() unless @_parser?

    unless typeof xml is "string"
      throw new Error("XML is not a string!")

    @_parser(xml)

  @_getParser: ->
    @_parser = if @_domParserAvailable()
      @_domParser
    else if @_xmlDomAvailable()
      @_xmlDomParser
    else
      throw new Error("No XML parser found, can't parse XML")

  @_domParserAvailable: ->
    window.DOMParser?

  @_xmlDomAvailable: ->
    window.ActiveXObject? and window.ActiveXObject?("Microsoft.XMLDOM")

  @_domParser: (xml) ->
    new window.DOMParser().parseFromString(xml, "text/xml")

  @_xmlDomParser: (xml) ->
    xmlDoc = new window.ActiveXObject("Microsoft.XMLDOM")
    xmlDoc.async = "false"
    xmlDoc.loadXML(xml)

