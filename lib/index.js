(function() {
  var cache, config, debug, getInstance, inspect, purgeCache, stringify, unset, _base, _base1;

  if ((_base = process.env).SUPPRESS_NO_CONFIG_WARNING == null) {
    _base.SUPPRESS_NO_CONFIG_WARNING = "y";
  }

  config = require("config");

  config.util.setModuleDefaults("debug-plus", {
    "default": "*:warn(:[0-9]+)?,*:error(:[0-9]+)?",
    showProcess: false,
    breakOnError: false
  });

  if ((_base1 = process.env).DEBUG == null) {
    _base1.DEBUG = config.get("debug-plus.default");
  }

  debug = require("debug");

  cache = {};

  inspect = function(p_object, p_showHidden, p_depth, p_colors) {
    var util;
    if (p_showHidden == null) {
      p_showHidden = false;
    }
    if (p_depth == null) {
      p_depth = null;
    }
    if (p_colors == null) {
      p_colors = true;
    }
    util = require("util");
    if (arguments.length === 2 && _.isObject(p_showHidden)) {
      return util.inspect(p_object, p_showHidden);
    }
    return util.inspect(p_object, {
      showHidden: p_showHidden,
      depth: p_depth,
      colors: p_colors
    });
  };

  stringify = function(p_object, p_replacer, p_space) {
    if (p_space == null) {
      p_space = 4;
    }
    return JSON.stringify(p_object, p_replacer, p_space);
  };

  getInstance = function(p_key) {
    var processString, _;
    _ = require("lodash");
    if (cache[p_key] != null) {
      return cache[p_key];
    }
    processString = config.get("debug-plus.showProcess").toString() === true.toString() ? ":" + process.pid : "";
    cache[p_key] = (function() {
      var debugInstance;
      debugInstance = debug("" + p_key + ":log" + processString);
      debugInstance.log = console.log.bind(console);
      return function() {
        return debugInstance.apply(debugInstance, arguments);
      };
    })();
    Object.defineProperty(cache[p_key], "get", {
      enumerable: true,
      get: getInstance
    });
    Object.defineProperty(cache[p_key], "log", {
      enumerable: true,
      get: function() {
        return cache[p_key];
      }
    });
    Object.defineProperty(cache[p_key], "warn", {
      enumerable: true,
      get: _.once(function() {
        var logger;
        logger = debug("" + p_key + ":warn" + processString);
        logger.log = console.warn.bind(console);
        return logger;
      })
    });
    Object.defineProperty(cache[p_key], "error", {
      enumerable: true,
      get: _.once(function() {
        var logger;
        logger = debug("" + p_key + ":error" + processString);
        logger.log = console.error.bind(console);
        return function(p_error, p_inspect, p_break) {
          var error, errorString, strings;
          if (p_inspect == null) {
            p_inspect = false;
          }
          if (p_break == null) {
            p_break = false;
          }
          if (p_error == null) {
            throw new Error("p_error was undefined @ " + p_key);
          }
          errorString = function(p_error) {
            var message;
            message = p_inspect ? inspect(p_error) : p_error.stack != null ? p_error.stack : p_error.message != null ? p_error.message : p_error.toString();
            return message;
          };
          if (p_break === true || config.get("debug-plus.breakOnError").toString() === true.toString()) {
            debugger;
          }
          if (_.isString(p_error)) {
            return logger(p_error);
          } else if (_.isArray(p_error)) {
            strings = (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = p_error.length; _i < _len; _i++) {
                error = p_error[_i];
                _results.push(errorString(error));
              }
              return _results;
            })();
            return logger(strings.join("\n"));
          } else {
            return logger(errorString(p_error));
          }
        };
      })
    });
    Object.defineProperty(cache[p_key], "dir", {
      enumerable: true,
      get: _.once(function() {
        var logger;
        logger = debug("" + p_key + ":dir" + processString);
        logger.log = console.log.bind(console);
        return function(p_object, p_showHidden, p_depth, p_colors) {
          if (p_showHidden == null) {
            p_showHidden = false;
          }
          if (p_depth == null) {
            p_depth = null;
          }
          if (p_colors == null) {
            p_colors = true;
          }
          return logger(inspect(p_object, p_showHidden, p_depth, p_colors));
        };
      })
    });
    Object.defineProperty(cache[p_key], "inspect", {
      enumerable: true,
      get: inspect
    });
    Object.defineProperty(cache[p_key], "stringify", {
      enumerable: true,
      get: _.once(function() {
        var logger;
        logger = debug("" + p_key + ":stringify" + processString);
        logger.log = console.log.bind(console);
        return function(p_object, p_replacer, p_space) {
          if (p_space == null) {
            p_space = 4;
          }
          return logger("\n" + (stringify(p_object, p_replacer, p_space)));
        };
      })
    });
    Object.defineProperty(cache[p_key], "timestamp", {
      enumerable: true,
      get: _.once(function() {
        var logger;
        logger = debug("" + p_key + ":benchmark" + processString);
        logger.log = console.log.bind(console);
        return function(p_message) {
          var message;
          message = new Date().toISOString();
          if (p_message != null) {
            message = "" + message + " - " + p_message;
          }
          return logger(message);
        };
      })
    });
    return cache[p_key];
  };

  unset = function(p_key) {
    return delete cache[p_key];
  };

  purgeCache = function() {
    return cache = {};
  };

  getInstance("debug-plus").log("🚀  Initialized" + (process.env.NODE_ENV != null ? " | Current configuration: '" + process.env.NODE_ENV + "'" : ""));

  unset("debug-plus");

  getInstance.get = getInstance;

  getInstance.inspect = inspect;

  getInstance.stringify = stringify;

  getInstance.unset = unset;

  getInstance.purgeCache = purgeCache;

  module.exports = getInstance;

}).call(this);
