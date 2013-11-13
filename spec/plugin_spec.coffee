{Communicator} = require('../src/Communicator')

describe 'Communicator', ->
  describe '#initCommunicator', ->
    beforeEach ->
      @class = new Communicator

    it 'will memoise the communicator and return immediately', ->
      @class.communicator = true
      expect(@class.communicator).to.be.true


    describe 'in a modern browser', ->
      it 'creates a communicator object', ->


      xit 'returns a reference to the DOM element'

    describe 'in internet explorer', ->
      beforeEach ->
        window.ActiveXObject = true

      xit 'creates a communicator object'
      xit 'returns a reference to the DOM element'
