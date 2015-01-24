# # Debug Plus

# Debug Plus proxies and extends the `debug` module by adding semantic sugar for
# `console`-style logging of various types of messages such as 'log', `warn`,
# `error`, or even `dir`.
#
# Additional helper methods such as `stringify`, `inspect`, and `timestamp` are
# also available to help the debugging process.

# Utilize the `config` module under the `debug-plus` namespace
process.env.SUPPRESS_NO_CONFIG_WARNING ?= "y"
config = require "config"

config.util.setModuleDefaults "debug-plus",
	default: "*:warn(:[0-9]+)?,*:error(:[0-9]+)?"
	showProcess: false
	breakOnError: false

# The debug module uses process.env to dictate its default state.
process.env.DEBUG ?= config.get "debug-plus.default"
debug = require "debug"
_ = require "lodash"

cache = {}

# Shim default `inspect` options
inspect = (p_object, p_showHidden=false, p_depth=null, p_colors=true) ->
	util = require "util"

	# Support Node v0.8+ {object, options} parameters
	if arguments.length is 2 and _.isObject p_showHidden
		return util.inspect p_object, p_showHidden

	return util.inspect p_object,
		showHidden: p_showHidden
		depth: p_depth
		colors: p_colors

# Shim default `stringify` options
stringify = (p_object, p_replacer, p_space=4) ->
	return JSON.stringify p_object, p_replacer, p_space

# Proxy calls to `debug` and decorate with sugar methods
getInstance = (p_key) ->
	if not p_key?
		throw new Error "`key` is a required property for `getInstance()`"

	if cache[p_key]?
		return cache[p_key]

	processString =
		if config.get("debug-plus.showProcess").toString() is true.toString()
			":#{process.pid}"
		else
			""

	cache[p_key] = do ->
		debugInstance = debug "#{p_key}:log#{processString}"
		debugInstance.log = console.log.bind console

		return ->
			debugInstance.apply debugInstance, arguments

	Object.defineProperty cache[p_key], "get",
		enumerable: true
		get: ->
			return getInstance

	Object.defineProperty cache[p_key], "log",
		enumerable: true
		get: ->
			return cache[p_key]

	# Pipe output to console.warn
	Object.defineProperty cache[p_key], "warn",
		enumerable: true
		get: _.once ->
			logger = debug "#{p_key}:warn#{processString}"
			logger.log = console.warn.bind console
			return logger

	# Pipe output to console.error and optionally parse Error objects
	Object.defineProperty cache[p_key], "error",
		enumerable: true
		get: _.once ->
			logger = debug "#{p_key}:error#{processString}"
			logger.log = console.error.bind console

			return (p_error, p_inspect=false, p_break=false) ->
				if not p_error?
					throw new Error "p_error was undefined @ #{p_key}"

				errorString = (p_error) ->
					message =
						if p_inspect
							inspect p_error
						else if p_error.stack?
							p_error.stack
						else if p_error.message?
							p_error.message
						else
							p_error.toString()

					return message

				# Allows an easy hook for setting a debug breakpoint
				if p_break is true or config.get("debug-plus.breakOnError").toString() is true.toString()
					debugger

				if _.isString p_error
					logger p_error
				else if _.isArray p_error
					strings = for error in p_error
						errorString error

					logger strings.join "\n"
				else
					logger errorString p_error

	# Enable console.dir-like functionality for `debug`
	Object.defineProperty cache[p_key], "dir",
		enumerable: true
		get: _.once ->
			logger = debug "#{p_key}:dir#{processString}"
			logger.log = console.log.bind console

			return (p_object, p_showHidden=false, p_depth=null, p_colors=true) ->
				logger inspect p_object, p_showHidden, p_depth, p_colors

	# Allow the inspection of objects with sensible defaults
	Object.defineProperty cache[p_key], "inspect",
		enumerable: true
		get: inspect

	# Log a JSON.stingifiy string with pretty-print enabled
	Object.defineProperty cache[p_key], "stringify",
		enumerable: true
		get: _.once ->
			logger = debug "#{p_key}:stringify#{processString}"
			logger.log = console.log.bind console

			return (p_object, p_replacer, p_space=4) ->
				logger "\n#{stringify p_object, p_replacer, p_space}"

	# Timestamp execution and optionally provide a message
	Object.defineProperty cache[p_key], "timestamp",
		enumerable: true
		get: _.once ->
			logger = debug "#{p_key}:benchmark#{processString}"
			logger.log = console.log.bind console

			return (p_message) ->
				message = new Date().toISOString()

				if p_message?
					message = "#{message} - #{p_message}"

				logger message

	return cache[p_key]

# Support targeted cache cleanup
unset = (p_key) ->
	delete cache[p_key]

# Purge the cache
purgeCache = ->
	cache = {}

getInstance("debug-plus").log "🚀  Initialized#{if process.env.NODE_ENV? then " | Current configuration: '" + process.env.NODE_ENV + "'" else ""}"
# Clean up `debug-plus` instance
unset "debug-plus"

# Attach helper methods
getInstance.get = getInstance
getInstance.inspect = inspect
getInstance.stringify = stringify
getInstance.unset = unset
getInstance.purgeCache = purgeCache

module.exports = getInstance
