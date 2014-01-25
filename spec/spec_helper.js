jsdom = require('jsdom').jsdom;
document = jsdom('<html><head><script></script></head><body></body></html>');
window = document.createWindow();
jQuery = $ = require('jquery')
jQuery(window);
navigator = window.navigator = {};
DEBUG = false;
navigator.userAgent = 'NodeJs JsDom';
navigator.appVersion = '';
window.DOMParser = require('xmldom').DOMParser;

Q = require('q');
_ = require('lodash/dist/lodash.underscore');
sinon = require('sinon');
chai = require('chai');
expect = chai.expect;
