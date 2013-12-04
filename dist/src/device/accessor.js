// Generated by CoffeeScript 1.6.3
(function() {
  var Accessor, Communicator, XMLParser,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Communicator = require('../../src/communicator').Communicator;

  XMLParser = require('../utils/xmlparser').XMLParser;

  exports.Accessor = Accessor = (function() {
    "use strict";
    Accessor.prototype.PERCENT_REGEX = /^[0-9]+%/;

    Accessor.prototype.STATUS_CODES = {
      idle: 0,
      working: 1,
      waiting: 2,
      finished: 3
    };

    function Accessor(device, dataType, pluginMethod) {
      this.device = device;
      this.dataType = dataType;
      this.pluginMethod = pluginMethod;
      this._checkFinished = __bind(this._checkFinished, this);
      this.communicator = Communicator.get();
      this.pluginAction = "" + this.ACTION + this.pluginMethod;
    }

    Accessor.prototype.perform = function() {
      this.deferred = Q.defer();
      if (this.communicator.busy()) {
        throw new Error("Plugin is busy");
      }
      this.communicator.invoke(this._startPluginAction(), this.device.number, this.dataType);
      return this.deferred.promise;
    };

    Accessor.prototype._startPluginAction = function() {
      return "Start" + this.pluginAction;
    };

    Accessor.prototype._finishPluginAction = function() {
      return "Finish" + this.pluginAction;
    };

    Accessor.prototype._checkFinished = function(deferred) {
      switch (this.communicator.invoke(this._finishPluginAction())) {
        case this.STATUS_CODES.working:
          return this._onWorking(deferred);
        case this.STATUS_CODES.finished:
          return this._onFinished(deferred);
        case this.STATUS_CODES.waiting:
          return this._onWaiting(deferred);
        case this.STATUS_CODES.idle:
          return this._onIdle(deferred);
        default:
          throw new Error("Unexpected Velociraptor.");
      }
    };

    Accessor.prototype._onWorking = function(deferred) {
      var _this = this;
      deferred.notify(this._progress());
      return setTimeout((function() {
        return _this._checkFinished(deferred);
      }), 100);
    };

    Accessor.prototype._onWaiting = function(deferred) {
      var _this = this;
      return setTimeout((function() {
        return _this._checkFinished(deferred);
      }), 500);
    };

    Accessor.prototype._onIdle = function(deferred) {
      return deferred.reject();
    };

    Accessor.prototype._onFinished = function() {
      throw new Error("Not Implemented");
    };

    Accessor.prototype._progress = function() {
      var progress, progressXml, _ref,
        _this = this;
      progress = {
        content: [],
        percent: 0
      };
      progressXml = this._getProgressXml().getElementsByTagName("ProgressWidget")[0];
      progress.message = (_ref = progressXml.getElementsByTagName("Title")[0]) != null ? _ref.textContent : void 0;
      _.each(progressXml.getElementsByTagName("Text"), function(node) {
        if (node.textContent.match(_this.PERCENT_REGEX)) {
          return progress.percent = parseInt(node.textContent, 10);
        } else {
          return progress.content.push(node.textContent);
        }
      });
      return progress;
    };

    Accessor.prototype._getProgressXml = function() {
      var xml;
      xml = this.communicator.read("ProgressXml");
      return XMLParser.parse(xml);
    };

    return Accessor;

  })();

}).call(this);

/*
//@ sourceMappingURL=accessor.map
*/
