jsdom = require('jsdom').jsdom;
document = jsdom('<html><head><script></script></head><body></body></html>');
window = document.createWindow();
jQuery = $ = require('jquery').create(window);
navigator = window.navigator = {};
DEBUG = false;
navigator.userAgent = 'NodeJs JsDom';
navigator.appVersion = '';
window.DOMParser = require('xmldom').DOMParser;

// Test requirements
Q         = require('q');
_         = require('underscore');
sinon     = require('sinon');
chai      = require('chai');
expect    = chai.expect;
