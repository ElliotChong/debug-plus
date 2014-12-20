# `process.env.DEBUG` must be defined before the module is loaded
process.env.DEBUG ?= "test*"

# Wrap `process.stdout.write` to capture logged messages
logs = {}

wrapWritableProcessStream = (p_key) ->
	logs[p_key] ?= []

	process[p_key].write = ((p_write) ->
		(p_string, p_encoding, p_fd) ->
			p_write.apply process[p_key], arguments
			logs[p_key].push p_string
	) process[p_key].write

for key in ["stdout", "stderr"]
	wrapWritableProcessStream key

assert = require("chai").assert
debug = require "../"

console.log process.env.DEBUG

describe "debug-plus", ->
	instance = null
	testObject = foo: bar: baz: bang: blam: going: super: deep: "here"

	describe "API", ->

		describe "debug('test-self')", ->
			it "returns a new debug instance", ->
				instance = debug "test-self"
				assert.isFunction instance, "Executing `debug-plus` should return a function"

			it "emits a message to stdout", ->
				message = "testing self"
				instance message
				assert new RegExp(message).test(logs.stdout.slice -1), "'#{message}' should be the last emitted message, instead saw '#{logs.stdout.slice -1}'"

		describe "debug.get('test-get')", ->
			it "returns a new debug instance", ->
				instance = debug.get "test-get"
				assert.isFunction instance, "Executing `debug-plus.get` should return a function"

			it "emits a message to stdout when self-executed", ->
				message = "testing get"
				instance message
				assert new RegExp(message).test(logs.stdout.slice -1), "'#{message}' should be the last emitted message, instead saw '#{logs.stdout.slice -1}'"

		describe "debug('test-get').log()", ->
			it "emits a message to stdout", ->
				message = "testing log"
				instance.log message
				assert new RegExp(message).test(logs.stdout.slice -1), "'#{message}' should be the last emitted message, instead saw '#{logs.stdout.slice -1}'"

		describe "debug('test-get').dir()", ->
			it "emits a `util.inspect` to stdout", ->
				message = testObject.toString()

				instance.dir testObject
				assert new RegExp(message).test(logs.stdout.slice -1), "'#{message}' should be the last emitted message, instead saw '#{logs.stdout.slice -1}'"

		describe "debug('test-get').warn()", ->
			it "emits a message to stderr", ->
				message = "testing warn"
				instance.warn message
				assert new RegExp(message).test(logs.stderr.slice -1), "'#{message}' should be the last emitted message, instead saw '#{JSON.stringify logs, null, 4}'"

		describe "debug('test-get').error()", ->
			it "emits a message to stderr", ->
				message = "testing error"
				instance.error message
				assert new RegExp(message).test(logs.stderr.slice -1), "'#{message}' should be the last emitted message, instead saw '#{logs.stderr.slice -1}'"

		describe "debug('test-get').stringify()", ->
			it "emits a readable JSON-style object to stdout", ->
				message = JSON.stringify testObject, null, 4

				instance.stringify testObject
				assert new RegExp(message).test(logs.stdout.slice -1), "'#{message}' should be the last emitted message, instead saw '#{logs.stdout.slice -1}'"
