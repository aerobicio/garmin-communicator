
describe 'accessor', ->
  it '.pluginAction'

  describe '#perform', ->
    it 'throws an error if the communicator is busy'
    it 'returns a promise'
    it 'starts checking for the invoked actions finished state'

    describe 'invoking the action on the communicator', ->
      it 'applies using the plugin start action'
      it 'applies using the device number'
      it 'applies using the data type'
      it 'applies using the arguments passed in to perform'
