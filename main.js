/******/ (function(modules) { // webpackBootstrap
/******/ 	// shortcut for better minimizing
/******/ 	var exports = "exports";
/******/ 	
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/ 	
/******/ 	// The require function
/******/ 	function require(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId][exports];
/******/ 		
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/ 		
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module[exports], module, module[exports], require);
/******/ 		
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/ 		
/******/ 		// Return the exports of the module
/******/ 		return module[exports];
/******/ 	}
/******/ 	
/******/ 	
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	require.modules = modules;
/******/ 	
/******/ 	// expose the module cache
/******/ 	require.cache = installedModules;
/******/ 	
/******/ 	// __webpack_public_path__
/******/ 	require.p = "";
/******/ 	
/******/ 	
/******/ 	// Load entry module and return exports
/******/ 	return require(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, require) {

	module.exports = require(7);


/***/ },
/* 1 */
/***/ function(module, exports, require) {

	var Communicator, Plugin, XMLParser,
	  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
	  __slice = [].slice;

	Plugin = require(8).Plugin;

	XMLParser = require(2).XMLParser;

	exports.Communicator = Communicator = (function() {
	  "use strict";
	  var PrivateCommunicator, _configuration, _instance;

	  function Communicator() {}

	  _configuration = null;

	  _instance = null;

	  Communicator.get = function(configuration) {
	    if (configuration) {
	      _configuration = configuration;
	    }
	    return _instance || (_instance = new PrivateCommunicator(_configuration));
	  };

	  Communicator.destroy = function() {
	    _instance = null;
	  };

	  PrivateCommunicator = (function() {
	    PrivateCommunicator.prototype.pluginIsInstalled = null;

	    function PrivateCommunicator(configuration) {
	      this.devices = __bind(this.devices, this);
	      this.configuration = configuration;
	      this.plugin = new Plugin();
	      this.pluginIsInstalled = this.plugin.pluginIsInstalled();
	      this.pluginProxy = this.plugin.el;
	    }

	    PrivateCommunicator.prototype.invoke = function() {
	      var args, fn, name;
	      name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
	      fn = this.pluginProxy[name];
	      if ((fn != null) && typeof fn === 'function') {
	        return fn.apply(this.pluginProxy, args);
	      } else {
	        throw new Error("'" + name + "' function does not exist!");
	      }
	    };

	    PrivateCommunicator.prototype.write = function(name, data) {
	      if (this.pluginProxy.hasOwnProperty(name)) {
	        this.pluginProxy[name] = data;
	        return true;
	      } else {
	        return false;
	      }
	    };

	    PrivateCommunicator.prototype.read = function(name) {
	      if (this.pluginProxy.hasOwnProperty(name)) {
	        return this.pluginProxy[name];
	      } else {
	        return false;
	      }
	    };

	    PrivateCommunicator.prototype.busy = function(value) {
	      if (value != null) {
	        this._busy = value;
	      }
	      return this._busy || false;
	    };

	    PrivateCommunicator.prototype.isLocked = function() {
	      return this.pluginProxy.Locked;
	    };

	    PrivateCommunicator.prototype.unlock = function(unlockCodes) {
	      var unlocked,
	        _this = this;
	      if (this.isLocked()) {
	        unlocked = false;
	        _(unlockCodes).map(function(unlockKey, domain) {
	          return unlocked || (unlocked = _this.invoke('Unlock', domain, unlockKey));
	        });
	        return unlocked;
	      }
	    };

	    PrivateCommunicator.prototype.devices = function() {
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

	    PrivateCommunicator.prototype._findDevices = function(deferred) {
	      this.invoke('StartFindDevices');
	      return this._loopUntilFinishedFindingDevices(deferred);
	    };

	    PrivateCommunicator.prototype._loopUntilFinishedFindingDevices = function(deferred) {
	      var _this = this;
	      if (this.invoke('FinishFindDevices')) {
	        return deferred.resolve(this._parseDeviceXml());
	      } else {
	        return setTimeout((function() {
	          return _this._loopUntilFinishedFindingDevices(deferred);
	        }), 100);
	      }
	    };

	    PrivateCommunicator.prototype._parseDeviceXml = function() {
	      var Device, xml;
	      Device = require(5).Device;
	      xml = XMLParser.parse(this.invoke('DevicesXmlString'));
	      return _(xml.getElementsByTagName("Device")).map(function(device) {
	        var name, number;
	        name = device.getAttribute("DisplayName");
	        number = parseInt(device.getAttribute("Number"), 10);
	        return new Device(number, name);
	      });
	    };

	    return PrivateCommunicator;

	  })();

	  return Communicator;

	}).call(this);

	/*
	//@ sourceMappingURL=communicator.js.map
	*/


/***/ },
/* 2 */
/***/ function(module, exports, require) {

	var XMLParser;

	exports.XMLParser = XMLParser = (function() {
	  "use strict";
	  function XMLParser() {}

	  XMLParser.parse = function(xml) {
	    if (this._parser == null) {
	      this._getParser();
	    }
	    if (typeof xml !== "string") {
	      throw new Error("XML is not a string!");
	    }
	    return this._parser(xml);
	  };

	  XMLParser._getParser = function() {
	    return this._parser = (function() {
	      if (this._domParserAvailable()) {
	        return this._domParser;
	      } else if (this._xmlDomAvailable()) {
	        return this._xmlDomParser;
	      } else {
	        throw new Error("No XML parser found, can't parse XML");
	      }
	    }).call(this);
	  };

	  XMLParser._domParserAvailable = function() {
	    return window.DOMParser != null;
	  };

	  XMLParser._xmlDomAvailable = function() {
	    return (window.ActiveXObject != null) && (typeof window.ActiveXObject === "function" ? window.ActiveXObject("Microsoft.XMLDOM") : void 0);
	  };

	  XMLParser._domParser = function(xml) {
	    return new window.DOMParser().parseFromString(xml, "text/xml");
	  };

	  XMLParser._xmlDomParser = function(xml) {
	    var xmlDoc;
	    xmlDoc = new window.ActiveXObject("Microsoft.XMLDOM");
	    xmlDoc.async = "false";
	    return xmlDoc.loadXML(xml);
	  };

	  return XMLParser;

	})();

	/*
	//@ sourceMappingURL=xmlparser.js.map
	*/


/***/ },
/* 3 */
/***/ function(module, exports, require) {

	var Accessor, Communicator, FitWorkoutFactory, Reader, TcxWorkoutFactory, _ref,
	  __hasProp = {}.hasOwnProperty,
	  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

	Communicator = require(1).Communicator;

	Accessor = require(6).Accessor;

	FitWorkoutFactory = require(10).FitWorkoutFactory;

	TcxWorkoutFactory = require(12).TcxWorkoutFactory;

	exports.Reader = Reader = (function(_super) {
	  __extends(Reader, _super);

	  "use strict";

	  function Reader() {
	    _ref = Reader.__super__.constructor.apply(this, arguments);
	    return _ref;
	  }

	  Reader.prototype.ACTION = "Read";

	  Reader.prototype.perform = function() {
	    this.clearDeviceXmlBuffers();
	    Reader.__super__.perform.apply(this, arguments);
	    return this.deferred.promise;
	  };

	  Reader.prototype.clearDeviceXmlBuffers = function() {
	    this.communicator.write("TcdXml", "");
	    return this.communicator.write("DirectoryListingXml", "");
	  };

	  Reader.prototype._onFinished = function(deferred) {
	    deferred.notify({
	      percent: 100
	    });
	    return deferred.resolve(this.handleFinishedReading());
	  };

	  Reader.prototype.handleFinishedReading = function() {
	    switch (this.pluginMethod) {
	      case 'FITDirectory':
	        return this.handleReadFITDirectory();
	      case 'FitnessDirectory':
	        return this.handleReadFitnessDirectory();
	      case 'FitnessDetail':
	        return this.handleReadFitnessDetail();
	    }
	  };

	  Reader.prototype.handleReadFITDirectory = function() {
	    var data;
	    data = this.communicator.read("DirectoryListingXml");
	    return new FitWorkoutFactory(this.device).produce(data);
	  };

	  Reader.prototype.handleReadFitnessDirectory = function() {
	    var data;
	    data = this.communicator.read("TcdXml");
	    return new TcxWorkoutFactory(this.device).produce(data);
	  };

	  Reader.prototype.handleReadFitnessDetail = function() {
	    return this.communicator.read("TcdXml");
	  };

	  return Reader;

	})(Accessor);

	/*
	//@ sourceMappingURL=reader.js.map
	*/


/***/ },
/* 4 */
/***/ function(module, exports, require) {

	var WorkoutFactory;

	exports.WorkoutFactory = WorkoutFactory = (function() {
	  "use strict";
	  WorkoutFactory.prototype.FITFILE_TYPES = {
	    activities: 4,
	    goals: 11,
	    locations: 8,
	    monitoring: 9,
	    profiles: 2,
	    schedules: 7,
	    sports: 3,
	    totals: 10
	  };

	  function WorkoutFactory(device) {
	    this.device = device;
	  }

	  WorkoutFactory.prototype._parseISODateString = function(dateString) {
	    var formattedDateString;
	    this.REPLACE_DATE_DASHES_REGEX || (this.REPLACE_DATE_DASHES_REGEX = /-/g);
	    this.REPLACE_DATE_TZ_REGEX || (this.REPLACE_DATE_TZ_REGEX = /[TZ]/g);
	    formattedDateString = dateString.replace(this.REPLACE_DATE_DASHES_REGEX, "/").replace(this.REPLACE_DATE_TZ_REGEX, " ");
	    return new Date(formattedDateString);
	  };

	  return WorkoutFactory;

	})();

	/*
	//@ sourceMappingURL=workout_factory.js.map
	*/


/***/ },
/* 5 */
/***/ function(module, exports, require) {

	var Communicator, Device, Reader, XMLParser;

	Communicator = require(1).Communicator;

	Reader = require(3).Reader;

	XMLParser = require(2).XMLParser;

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

	/*
	//@ sourceMappingURL=device.js.map
	*/


/***/ },
/* 6 */
/***/ function(module, exports, require) {

	var Accessor, Communicator, XMLParser,
	  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

	Communicator = require(1).Communicator;

	XMLParser = require(2).XMLParser;

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
	    var args, argsArray;
	    this.deferred = Q.defer();
	    if (this.communicator.busy()) {
	      throw new Error("Plugin is busy");
	    }
	    argsArray = Array.prototype.slice.call(arguments, 0);
	    args = [this._startPluginAction(), this.device.number, this.dataType].concat(argsArray);
	    this.communicator.invoke.apply(this.communicator, args);
	    this._checkFinished(this.deferred);
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
	    }), 150);
	  };

	  Accessor.prototype._onIdle = function(deferred) {
	    return deferred.reject();
	  };

	  Accessor.prototype._onFinished = function() {
	    throw new Error("Abstract method: Not Implemented");
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
	        progress.percent = parseInt(node.textContent, 10);
	      } else {
	        progress.content.push(node.textContent);
	      }
	      return node;
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

	/*
	//@ sourceMappingURL=accessor.js.map
	*/


/***/ },
/* 7 */
/***/ function(module, exports, require) {

	var Communicator, Garmin;

	Communicator = require(1).Communicator;

	window.Garmin = Garmin = (function() {
	  "use strict";
	  Garmin.prototype.DEFAULT_UNLOCK_CODES = {
	    "file:///": "cb1492ae040612408d87cc53e3f7ff3c",
	    "http://localhost": "45517b532362fc3149e4211ade14c9b2",
	    "http://127.0.0.1": "40cd4860f7988c53b15b8491693de133"
	  };

	  function Garmin(options) {
	    if (options == null) {
	      options = {};
	    }
	    this.configuration = _(options).defaults({
	      unlockCodes: this.mergeUnlockCodes(options.unlockCodes),
	      testMode: false
	    });
	    this.communicator = Communicator.get(this.configuration);
	    this.unlock();
	  }

	  Garmin.prototype.mergeUnlockCodes = function(unlockCodes) {
	    if (unlockCodes == null) {
	      unlockCodes = {};
	    }
	    return _(this.DEFAULT_UNLOCK_CODES).defaults(unlockCodes);
	  };

	  Garmin.prototype.isInstalled = function() {
	    return this.isInstalled = this.communicator.pluginIsInstalled || this.configuration.testMode;
	  };

	  Garmin.prototype.unlock = function() {
	    if (!this.configuration.testMode) {
	      return this.communicator.unlock(this.configuration.unlockCodes);
	    }
	  };

	  Garmin.prototype.devices = function() {
	    return this.communicator.devices();
	  };

	  return Garmin;

	})();

	/*
	//@ sourceMappingURL=garmin.js.map
	*/


/***/ },
/* 8 */
/***/ function(module, exports, require) {

	var Plugin;

	exports.Plugin = Plugin = (function() {
	  "use strict";
	  function Plugin() {
	    this.el || (this.el = this._createPluginEl());
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

	  Plugin.prototype.pluginIsInstalled = function() {
	    if (this.el.Unlock != null) {
	      return true;
	    } else {
	      return false;
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

	/*
	//@ sourceMappingURL=plugin.js.map
	*/


/***/ },
/* 9 */
/***/ function(module, exports, require) {

	var Communicator, FitWorkout;

	Communicator = require(1).Communicator;

	exports.FitWorkout = FitWorkout = (function() {
	  "use strict";
	  function FitWorkout(device, id, type, date, path) {
	    this.id = id;
	    this.device = device;
	    this.type = type;
	    this.date = date;
	    this.path = path;
	    this.communicator = Communicator.get();
	  }

	  FitWorkout.prototype.getData = function() {
	    var deferred;
	    deferred = Q.defer();
	    deferred.resolve(this._getBinaryFile());
	    return deferred.promise;
	  };

	  FitWorkout.prototype._getBinaryFile = function() {
	    return this.communicator.invoke("GetBinaryFile", this.device.number, this.path, false);
	  };

	  return FitWorkout;

	})();

	/*
	//@ sourceMappingURL=fit_workout.js.map
	*/


/***/ },
/* 10 */
/***/ function(module, exports, require) {

	var FitWorkout, FitWorkoutFactory, WorkoutFactory, XMLParser, _ref,
	  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
	  __hasProp = {}.hasOwnProperty,
	  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

	XMLParser = require(2).XMLParser;

	WorkoutFactory = require(4).WorkoutFactory;

	FitWorkout = require(9).FitWorkout;

	exports.FitWorkoutFactory = FitWorkoutFactory = (function(_super) {
	  __extends(FitWorkoutFactory, _super);

	  "use strict";

	  function FitWorkoutFactory() {
	    this._filterFitFileXmlType = __bind(this._filterFitFileXmlType, this);
	    this._objectForFileNode = __bind(this._objectForFileNode, this);
	    _ref = FitWorkoutFactory.__super__.constructor.apply(this, arguments);
	    return _ref;
	  }

	  FitWorkoutFactory.prototype.produce = function(data) {
	    var xml;
	    xml = XMLParser.parse(data);
	    return _.chain(xml.getElementsByTagName("File")).filter(this._filterFitFileXmlType).map(this._objectForFileNode).value();
	  };

	  FitWorkoutFactory.prototype._objectForFileNode = function(file) {
	    var date, id, path, type;
	    id = this._getIdForFileNode(file);
	    type = this._getFileTypeForFileNode(file);
	    date = this._getCreationTimeFileNode(file);
	    path = this._getPathForFileNode(file);
	    return new FitWorkout(this.device, id, type, date, path);
	  };

	  FitWorkoutFactory.prototype._getCreationTimeFileNode = function(file) {
	    var dateTimeString;
	    dateTimeString = file.getElementsByTagName("CreationTime")[0].textContent;
	    return this._parseISODateString(dateTimeString);
	  };

	  FitWorkoutFactory.prototype._filterFitFileXmlType = function(file) {
	    return this._getFileTypeForFileNode(file) === this.FITFILE_TYPES.activities;
	  };

	  FitWorkoutFactory.prototype._getIdForFileNode = function(fileXml) {
	    return parseInt(fileXml.getElementsByTagName("FitId")[0].getElementsByTagName("Id")[0].textContent, 10);
	  };

	  FitWorkoutFactory.prototype._getFileTypeForFileNode = function(fileXml) {
	    return parseInt(fileXml.getElementsByTagName("FitId")[0].getElementsByTagName("FileType")[0].textContent, 10);
	  };

	  FitWorkoutFactory.prototype._getPathForFileNode = function(file) {
	    return file.getAttribute("Path");
	  };

	  return FitWorkoutFactory;

	})(WorkoutFactory);

	/*
	//@ sourceMappingURL=fit_workout_factory.js.map
	*/


/***/ },
/* 11 */
/***/ function(module, exports, require) {

	var TcxWorkout;

	exports.TcxWorkout = TcxWorkout = (function() {
	  "use strict";
	  function TcxWorkout(device, id, date) {
	    var Reader;
	    Reader = require(3).Reader;
	    this.device = device;
	    this.id = id;
	    this.date = date;
	    this.detailReader = new Reader(this.device, "FitnessHistory", "FitnessDetail");
	  }

	  TcxWorkout.prototype.getData = function() {
	    return this.detailReader.perform(this.id);
	  };

	  return TcxWorkout;

	})();

	/*
	//@ sourceMappingURL=tcx_workout.js.map
	*/


/***/ },
/* 12 */
/***/ function(module, exports, require) {

	var TcxWorkout, TcxWorkoutFactory, WorkoutFactory, XMLParser, _ref,
	  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
	  __hasProp = {}.hasOwnProperty,
	  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

	XMLParser = require(2).XMLParser;

	WorkoutFactory = require(4).WorkoutFactory;

	TcxWorkout = require(11).TcxWorkout;

	exports.TcxWorkoutFactory = TcxWorkoutFactory = (function(_super) {
	  __extends(TcxWorkoutFactory, _super);

	  "use strict";

	  function TcxWorkoutFactory() {
	    this._getFirstLapStartTime = __bind(this._getFirstLapStartTime, this);
	    this._objectForActivityNode = __bind(this._objectForActivityNode, this);
	    _ref = TcxWorkoutFactory.__super__.constructor.apply(this, arguments);
	    return _ref;
	  }

	  TcxWorkoutFactory.prototype.produce = function(data) {
	    var xml;
	    xml = XMLParser.parse(data);
	    return _.chain(xml.getElementsByTagName("Activity")).map(this._objectForActivityNode).value();
	  };

	  TcxWorkoutFactory.prototype._objectForActivityNode = function(activity) {
	    var date, id;
	    id = this._getIdForActivityNode(activity);
	    date = this._getFirstLapStartTime(activity);
	    return new TcxWorkout(this.device, id, date);
	  };

	  TcxWorkoutFactory.prototype._getFirstLapStartTime = function(activity) {
	    var dateTimeString;
	    dateTimeString = activity.getElementsByTagName("Lap")[0].getAttribute("StartTime");
	    return this._parseISODateString(dateTimeString);
	  };

	  TcxWorkoutFactory.prototype._getIdForActivityNode = function(activity) {
	    return activity.getElementsByTagName("Id")[0].textContent;
	  };

	  return TcxWorkoutFactory;

	})(WorkoutFactory);

	/*
	//@ sourceMappingURL=tcx_workout_factory.js.map
	*/


/***/ }
/******/ ])