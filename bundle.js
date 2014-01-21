/******/ (function(modules) { // webpackBootstrap
/******/ 	
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/ 	
/******/ 	// The require function
/******/ 	function require(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/ 		
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/ 		
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, require);
/******/ 		
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/ 		
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/******/ 	// The bundle contains no chunks. A empty chunk loading function.
/******/ 	require.e = function requireEnsure(_, callback) {
/******/ 		callback.call(null, this);
/******/ 	};
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

	(function() {
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

	}).call(this);


/***/ },
/* 1 */
/***/ function(module, exports, require) {

	(function() {
	  "use strict";
	  var Communicator, Plugin, XMLParser,
	    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
	    __slice = [].slice;

	  Plugin = require((function webpackMissingModule() { throw new Error("Cannot find module \"plugin\""); }())).Plugin;

	  XMLParser = require((function webpackMissingModule() { throw new Error("Cannot find module \"utils/xmlparser\""); }())).XMLParser;

	  exports.Communicator = Communicator = (function() {
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
	        var Device, xml,
	          _this = this;
	        Device = require((function webpackMissingModule() { throw new Error("Cannot find module \"src/device\""); }())).Device;
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

	}).call(this);


/***/ }
/******/ ])