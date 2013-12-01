;(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Communicator, Plugin, XMLParser,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = [].slice;

Plugin = require('../src/plugin').Plugin;

XMLParser = require('../src/utils/xmlparser').XMLParser;

exports.Communicator = Communicator = (function() {
  "use strict";
  var PrivateClass, instance;

  function Communicator() {}

  instance = null;

  Communicator.get = function() {
    return instance != null ? instance : instance = new PrivateClass;
  };

  Communicator.destroy = function() {
    return instance = null;
  };

  PrivateClass = (function() {
    function PrivateClass() {
      this.devices = __bind(this.devices, this);
      this.plugin = new Plugin();
      this.pluginProxy = this.plugin.el;
    }

    PrivateClass.prototype.invoke = function() {
      var args, fn, name;
      name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      fn = this.pluginProxy[name];
      if ((fn != null) && typeof fn === 'function') {
        return fn.apply(this.pluginProxy, args);
      } else {
        throw new Error("'" + name + "' function does not exist!");
      }
    };

    PrivateClass.prototype.write = function(name, data) {
      if (this.pluginProxy.hasOwnProperty(name)) {
        return this.pluginProxy[name] = data;
      }
    };

    PrivateClass.prototype.read = function(name) {
      if (this.pluginProxy.hasOwnProperty(name)) {
        return this.pluginProxy[name];
      }
    };

    PrivateClass.prototype.busy = function(value) {
      if (value != null) {
        this._busy = value;
      }
      return this._busy || false;
    };

    PrivateClass.prototype.isLocked = function() {
      return this.pluginProxy.Locked;
    };

    PrivateClass.prototype.unlock = function(unlock_codes) {
      if (this.isLocked()) {
        return true;
      }
    };

    PrivateClass.prototype.devices = function() {
      var deferred,
        _this = this;
      if (!this.busy()) {
        this.busy(true);
        this.unlock();
        deferred = Q.defer();
        deferred.promise["finally"](function() {
          return _this.busy(false);
        });
        this._findDevices(deferred);
        return deferred.promise;
      }
    };

    PrivateClass.prototype._findDevices = function(deferred) {
      this.invoke('StartFindDevices');
      return this._loopUntilFinishedFindingDevices(deferred);
    };

    PrivateClass.prototype._loopUntilFinishedFindingDevices = function(deferred) {
      var _this = this;
      if (this.invoke('FinishFindDevices')) {
        return deferred.resolve(this._parseDeviceXml());
      } else {
        return setTimeout((function() {
          return _this._loopUntilFinishedFindingDevices(deferred);
        }), 100);
      }
    };

    PrivateClass.prototype._parseDeviceXml = function() {
      var Device, xml,
        _this = this;
      Device = require('../src/device').Device;
      xml = XMLParser.parse(this.invoke('DevicesXmlString'));
      return _(xml.getElementsByTagName("Device")).map(function(device) {
        var name, number;
        name = device.getAttribute("DisplayName");
        number = parseInt(device.getAttribute("Number"));
        return new Device(number, name);
      });
    };

    return PrivateClass;

  })();

  return Communicator;

}).call(this);


},{"../src/device":2,"../src/plugin":7,"../src/utils/xmlparser":8}],2:[function(require,module,exports){
var Communicator, Device, Reader, XMLParser;

Communicator = require('../src/communicator').Communicator;

Reader = require('../src/device/reader').Reader;

XMLParser = require('../src/utils/xmlparser').XMLParser;

exports.Device = Device = (function() {
  "use strict";
  Device.prototype.ACTIONS = {
    Activities: ['FitnessHistory', 'FitnessDirectory'],
    Workouts: ['FitnessWorkouts', 'FitnessData'],
    Courses: ['FitnessCourses', 'FitnessData'],
    Goals: ['FitnessActivityGoals', 'FitnessData'],
    Profile: ['FitnessUserProfile', 'FitnessData'],
    FITActivities: ['FIT_TYPE_4', 'FITDirectory']
  };

  function Device(number, name) {
    this.number = number;
    this.name = name;
    this.communicator = Communicator.get();
    this.deviceDescriptionXml = this._getDeviceDescriptionXml();
    this._setDeviceInfo();
    this._setDeviceCapabilities();
    this._createDeviceAccessors();
  }

  Device.prototype.activities = function() {
    if (this.canReadFITActivities) {
      return this.readFITActivities();
    } else {
      return this.readActivities();
    }
  };

  Device.prototype._setDeviceCapabilities = function() {
    return _.each(this.ACTIONS, function(data, type) {
      this["canRead" + type] = this._canXY('Output', data[0]);
      return this["canWrite" + type] = this._canXY('Input', data[0]);
    }, this);
  };

  Device.prototype._createDeviceAccessors = function() {
    return _.each(this.ACTIONS, function(data, type) {
      this["read" + type] = this._reader(type, data[0], data[1]);
      return this["write" + type] = this._writer();
    }, this);
  };

  Device.prototype._reader = function(type, dataType, pluginMethod) {
    return function() {
      var reader;
      if (!this["canRead" + type]) {
        throw new Error("read" + type + " is not supported on this device");
      }
      reader = new Reader(this, dataType, pluginMethod);
      return reader.perform();
    };
  };

  Device.prototype._writer = function() {
    return function() {
      throw new Error("Not implemented");
    };
  };

  Device.prototype._canXY = function(method, dataTypeName) {
    var transferDirection, _ref, _ref1;
    transferDirection = (_ref = this._getDataTypeNodeForDataTypeName(dataTypeName)) != null ? (_ref1 = _ref.getElementsByTagName("File")[0]) != null ? _ref1.getElementsByTagName("TransferDirection")[0].textContent : void 0 : void 0;
    return (transferDirection != null) && new RegExp(method).test(transferDirection);
  };

  Device.prototype._getDataTypeNodeForDataTypeName = function(name) {
    var dataTypesXml;
    dataTypesXml = this._getDeviceDataTypesXml();
    if (dataTypesXml) {
      return _.filter(dataTypesXml, function(node) {
        return name === node.getElementsByTagName("Name")[0].textContent;
      })[0];
    }
  };

  Device.prototype._getDeviceDataTypesXml = function() {
    var _ref, _ref1;
    return this._deviceDataTypes || (this._deviceDataTypes = (_ref = this.deviceDescriptionXml) != null ? (_ref1 = _ref.getElementsByTagName("MassStorageMode")[0]) != null ? _ref1.getElementsByTagName("DataType") : void 0 : void 0);
  };

  Device.prototype._setDeviceInfo = function() {
    this.id = this._deviceId();
    this.name = this._deviceDisplayName();
    this.partNumber = this._devicePartNumber();
    return this.softwareVersion = this._softwareVersion();
  };

  Device.prototype._getDeviceDescriptionXml = function() {
    var xml;
    xml = this.communicator.invoke('DeviceDescription', this.number);
    return XMLParser.parse(xml);
  };

  Device.prototype._deviceId = function() {
    return this.deviceDescriptionXml.getElementsByTagName("Id")[0].textContent;
  };

  Device.prototype._deviceDisplayName = function() {
    var model;
    model = this.deviceDescriptionXml.getElementsByTagName("Model")[0];
    if (model.getElementsByTagName("DisplayName").length) {
      return model.getElementsByTagName("DisplayName")[0].textContent;
    } else {
      return model.getElementsByTagName("Description")[0].textContent;
    }
  };

  Device.prototype._devicePartNumber = function() {
    return this.deviceDescriptionXml.getElementsByTagName("Model")[0].getElementsByTagName("PartNumber")[0].textContent;
  };

  Device.prototype._softwareVersion = function() {
    return this.deviceDescriptionXml.getElementsByTagName("Model")[0].getElementsByTagName("SoftwareVersion")[0].textContent;
  };

  return Device;

})();


},{"../src/communicator":1,"../src/device/reader":4,"../src/utils/xmlparser":8}],3:[function(require,module,exports){
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


},{"../../src/communicator":1,"../utils/xmlparser":8}],4:[function(require,module,exports){
var Accessor, Communicator, FitFile, Reader, XMLParser, _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Communicator = require('../../src/communicator').Communicator;

Accessor = require('./accessor').Accessor;

XMLParser = require('../utils/xmlparser').XMLParser;

FitFile = require('../../src/fitfile').FitFile;

exports.Reader = Reader = (function(_super) {
  __extends(Reader, _super);

  "use strict";

  function Reader() {
    this._filterFileXmlType = __bind(this._filterFileXmlType, this);
    this._fitObjectForFile = __bind(this._fitObjectForFile, this);
    _ref = Reader.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Reader.prototype.ACTION = "Read";

  Reader.prototype.FITFILE_TYPES = {
    activities: 4,
    goals: 11,
    locations: 8,
    monitoring: 9,
    profiles: 2,
    schedules: 7,
    sports: 3,
    totals: 10
  };

  Reader.prototype.perform = function() {
    this._clearDeviceXmlBuffers();
    Reader.__super__.perform.apply(this, arguments);
    return this.deferred.promise;
  };

  Reader.prototype._clearDeviceXmlBuffers = function() {
    Communicator.get().write("TcdXml", "");
    return Communicator.get().write("DirectoryListingXml", "");
  };

  Reader.prototype._onFinished = function(deferred) {
    deferred.notify({
      percent: 100
    });
    return deferred.resolve(this._loadDataFromDirectory());
  };

  Reader.prototype._loadDataFromDirectory = function() {
    switch (this.pluginMethod) {
      case 'FitnessDirectory':
        return Communicator.get().read("TcdXml");
      case 'FITDirectory':
        return this._parseFitDirectory();
    }
  };

  Reader.prototype._parseFitDirectory = function() {
    var xml;
    xml = XMLParser.parse(this._getFitDirectoryXml());
    return _.chain(xml.getElementsByTagName("File")).filter(this._filterFileXmlType).map(this._fitObjectForFile).value();
  };

  Reader.prototype._fitObjectForFile = function(file) {
    var date, id, path, type;
    id = this._getIdForFile(file);
    type = this._getTypeDescriptionForFile(file);
    date = this._getDateObjectForFile(file);
    path = this._getPathForFile(file);
    return new FitFile(this.device, id, type, date, path);
  };

  Reader.prototype._filterFileXmlType = function(file) {
    return this._getTypeDescriptionForFile(file) === this.FITFILE_TYPES.activities;
  };

  Reader.prototype._getFitDirectoryXml = function() {
    return Communicator.get().read("DirectoryListingXml");
  };

  Reader.prototype._getIdForFile = function(fileXml) {
    return fileXml.getElementsByTagName("FitId")[0].getElementsByTagName("Id")[0].textContent;
  };

  Reader.prototype._getDateObjectForFile = function(fileXml) {
    var formattedDateString;
    this.REPLACE_DATE_DASHES_REGEX || (this.REPLACE_DATE_DASHES_REGEX = /-/g);
    this.REPLACE_DATE_TZ_REGEX || (this.REPLACE_DATE_TZ_REGEX = /[TZ]/g);
    formattedDateString = fileXml.getElementsByTagName("CreationTime")[0].textContent.replace(this.REPLACE_DATE_DASHES_REGEX, "/").replace(this.REPLACE_DATE_TZ_REGEX, " ");
    return new Date(formattedDateString);
  };

  Reader.prototype._getTypeDescriptionForFile = function(fileXml) {
    return parseInt(fileXml.getElementsByTagName("FitId")[0].getElementsByTagName("FileType")[0].textContent);
  };

  Reader.prototype._getPathForFile = function(file) {
    return file.getAttribute("Path");
  };

  return Reader;

})(Accessor);


},{"../../src/communicator":1,"../../src/fitfile":5,"../utils/xmlparser":8,"./accessor":3}],5:[function(require,module,exports){
var Communicator, FitFile;

Communicator = require('../src/communicator').Communicator;

exports.FitFile = FitFile = (function() {
  "use strict";
  FitFile.prototype.UUENCODE_HEADER_REGEX = /^.+\r*\n/;

  FitFile.prototype.UUENCODE_INVALID_CHARS_REGEX = /[^A-Za-z0-9\+\/\=]/g;

  function FitFile(device, id, type, data, path) {
    this.device = device;
    this.id = id;
    this.type = type;
    this.data = data;
    this.path = path;
    this.communicator = Communicator.get();
  }

  FitFile.prototype.getData = function() {
    var deferred;
    deferred = Q.defer();
    deferred.resolve(this._getBinaryFile());
    return deferred.promise;
  };

  FitFile.prototype._getBinaryFile = function() {
    return this.communicator.invoke("GetBinaryFile", this.device.number, this.path, false);
  };

  return FitFile;

})();


},{"../src/communicator":1}],6:[function(require,module,exports){
var Communicator, Garmin;

Communicator = require('../src/communicator').Communicator;

window.Garmin = Garmin = (function() {
  Garmin.DEFAULT_UNLOCK_CODES = {
    "file:///": "cb1492ae040612408d87cc53e3f7ff3c",
    "http://localhost": "45517b532362fc3149e4211ade14c9b2",
    "http://127.0.0.1": "40cd4860f7988c53b15b8491693de133"
  };

  function Garmin(options) {
    if (options == null) {
      options = {};
    }
    this.options = _(options).defaults({
      unlock_codes: this.DEFAULT_UNLOCK_CODES
    });
  }

  Garmin.prototype.devices = function() {
    return Communicator.get().devices();
  };

  return Garmin;

})();


},{"../src/communicator":1}],7:[function(require,module,exports){
var Plugin;

exports.Plugin = Plugin = (function() {
  "use strict";
  function Plugin() {
    this.el || (this.el = this._createPluginEl());
    this._checkIsInstalled();
  }

  Plugin.prototype.softwareVersion = function() {
    return this.el.getPluginVersion();
  };

  Plugin.prototype._createPluginEl = function() {
    if (this._smellsLikeIE()) {
      return this._createIEPlugin();
    } else {
      return this._createVanillaPlugin();
    }
  };

  Plugin.prototype._checkIsInstalled = function() {
    if (this.el.Unlock == null) {
      throw new Error("Garmin Communicator plugin not installed");
    }
  };

  Plugin.prototype._smellsLikeIE = function() {
    return window.ActiveXObject != null;
  };

  Plugin.prototype._createVanillaPlugin = function() {
    var comm, comm_wrapper;
    comm_wrapper = document.createElement('div');
    comm_wrapper.style.width = 0;
    comm_wrapper.style.height = 0;
    comm = document.createElement('object');
    comm.id = "GarminNetscapePlugin";
    comm.height = 0;
    comm.width = 0;
    comm.setAttribute("type", "application/vnd-garmin.mygarmin");
    comm_wrapper.appendChild(comm);
    document.body.appendChild(comm_wrapper);
    return comm;
  };

  Plugin.prototype._createIEPlugin = function() {
    var comm;
    comm = document.createElement('object');
    comm.id = "GarminActiveXControl";
    comm.style.width = 0;
    comm.style.height = 0;
    comm.style.visibility = "hidden";
    comm.height = 0;
    comm.width = 0;
    comm.setAttribute("classid", "CLSID:099B5A62-DE20-48C6-BF9E-290A9D1D8CB5");
    document.body.appendChild(comm);
    return comm;
  };

  return Plugin;

})();


},{}],8:[function(require,module,exports){
var XMLParser;

exports.XMLParser = XMLParser = (function() {
  "use strict";
  function XMLParser() {}

  XMLParser.parse = function(xml) {
    if (!this._parser) {
      this._getParser();
    }
    return this._parser(xml);
  };

  XMLParser._getParser = function() {
    return this._parser = (function() {
      if (window.DOMParser != null) {
        return function(xml) {
          return new window.DOMParser().parseFromString(xml, "text/xml");
        };
      } else if ((window.ActiveXObject != null) && window.ActiveXObject("Microsoft.XMLDOM")) {
        return function(xml) {
          var xmlDoc;
          xmlDoc = new window.ActiveXObject("Microsoft.XMLDOM");
          xmlDoc.async = "false";
          return xmlDoc.loadXML(xml);
        };
      } else {
        throw new Error("No XML parser found, can’t parse XML");
      }
    })();
  };

  return XMLParser;

})();


},{}]},{},[1,2,5,6,7])
;