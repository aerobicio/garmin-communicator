window.should = chai.should
window.expect = chai.expect
window.assert = chai.assert

mocha.setup "bdd"
mocha.bail false
mocha.reporter 'html'

if window.mochaPhantomJS
  mochaPhantomJS.run()
else
  mocha.run()
