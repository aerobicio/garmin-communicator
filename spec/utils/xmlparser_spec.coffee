{XMLParser} = require('../../src/utils/xmlparser')

describe 'XMLParser', ->
  describe "@parse", ->
    it "throws an error if not passed a string", ->
      expect(=> XMLParser.parse()).to.throw Error

    it "will parse xml from a string", ->
      xml = """
        <?xml version="1.0" ?>
        <Device></Device>
      """
      expect(typeof XMLParser.parse(xml)).to.equal "object"

  describe "selecting a DOM parser", ->
    beforeEach ->
      @domParserAvailableStub = sinon.stub(XMLParser, '_domParserAvailable')
      @xmlDomAvailableStub = sinon.stub(XMLParser, '_xmlDomAvailable')

    afterEach ->
      @domParserAvailableStub.restore()
      @xmlDomAvailableStub.restore()

    it "throws an error when no parser is available", ->
      @domParserAvailableStub.returns false
      @xmlDomAvailableStub.returns false
      expect(=> XMLParser._getParser()).to.throw Error

    describe "when DOMParser is available", ->
      beforeEach ->
        @domParserAvailableStub.returns true
        @parserStub = window.DOMParser = {parseFromString: -> return}

      it "uses DOMParser", ->
        XMLParser._getParser() is XMLParser._domParser

    describe "when XMLDOM is available", ->
      beforeEach ->
        @domParserAvailableStub.returns false
        @xmlDomAvailableStub.returns true

      it "uses XMLDOM", ->
        XMLParser._getParser() is XMLParser._xmlDomParser
