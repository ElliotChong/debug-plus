# Debug Plus

`debug-plus` is a drop-in replacement wrapper for the superb [debug](https://github.com/visionmedia/debug) node module and adds semantic sugar for `console`-style logging of various types of messages such as `log`, `warn`, `error`, or even `dir`.

Additional helper methods such as `stringify`, `inspect`, and `timestamp` are also available to help the debugging process.

![](https://www.dropbox.com/s/kxprl5wt0jjzau3/Screenshot%202014-12-19%2022.22.52.png?dl=1)

## Installation

```bash
$ npm install debug-plus
```

## Usage

As with the standard `debug` module you can simply invoke the exported `debug-plus` function to generate your debug function, passing it a name which will determine if a noop function is returned, or a decorated `console.log`, so all of the `console` format string goodies you're used to work fine. Additionally, `debug-plus` exposes semantic `console`-style functions on top of the standard `debug` method. A unique color is selected per-function for visibility.

Example _app.coffee_:

```coffee-script
debug = require("debug-plus") "app"
http = require "http"
name = "Awesome App"

# Standard `debug` style logging with String substitution
debug "booting %s", name

http.createServer (p_request, p_response) ->
	# `console.log` style logging
	debug.log "#{p_request.method} #{p_request.url}"

	# `console.warn` style logging
	if p_request.url is "/warn"
		debug.warn "#{p_request.url} is deprecated"

	# `console.error` style logging
	else if p_request.url is "/stringError"
		debug.error "#{p_request.url} is unsupported"

	# `console.error` style logging with a stack trace
	else if p_request.url is "/error"
		debug.error new Error "#{p_request.url} is unsopported"

	p_response.end "Click!\n"

require "./peon"
```

Example _peon.coffee_:

```coffee-script
	debug = require("debug-plus") "peon"

	setInterval ->
		debug.log "Zug zug!"
	, 3000
```

### Configuration

#### process.env.DEBUG

The __DEBUG__ environment variable is then used to enable these based on space or comma-delimited names.

When a default __DEBUG__ environment variable is unspecified `debug-plus` will default to `*:warn(:[0-9]+)?,*:error(:[0-9]+)?` to display warnings and errors.

#### node-config
`debug-plus` supports the [node-config](https://github.com/lorenwest/node-config) module for specifying project-level and environment-level configurations.

Example _./config/development.coffee_:

```coffee-script
module.exports =
	"debug-plus":
		default: "*" # Designate the namespace to log if `process.env.DEBUG` is undefined - Default: "*:warn(:[0-9]+)?,*:error(:[0-9]+)?"
		showProcess: false # Append the process id to the log messages (useful when working with clustering) - Default: false
		breakOnError: true # If working with a debugger (such as `node-inspector`) you can have debug-plus automatically break on a call to `debug.error()` - Default: false
```

Example _./config/production.coffee_:

```coffee-script
module.exports =
	"debug-plus":
		default: "*:warn(:[0-9]+)?,*:error(:[0-9]+)?" # Designate the namespace to log if `process.env.DEBUG` is undefined - Default: "*:warn(:[0-9]+)?,*:error(:[0-9]+)?"
		showProcess: true # Append the process id to the log messages (useful when working with clustering) - Default: false
		breakOnError: false # If working with a debugger (such as `node-inspector`) you can have debug-plus automatically break on a call to `debug.error()` - Default: false
```

## Conventions

If you're using this in one or more of your libraries, you _should_ use the name of your library so that developers may toggle debugging as desired without guessing names. If you have more than one debuggers you _should_ prefix them with your library name and use ":" to separate features. For example "bodyParser" from Connect would then be "connect:bodyParser".

## Wildcards

The `*` character may be used as a wildcard. Suppose for example your library has debuggers named "connect:bodyParser", "connect:compress", "connect:session", instead of listing all three with `DEBUG=connect:bodyParser,connect.compress,connect:session`, you may simply do `DEBUG=connect:*`, or to run everything using this module simply use `DEBUG=*`.

You can also exclude specific debuggers by prefixing them with a "-" character.  For example, `DEBUG=*,-connect:*` would include all debuggers except those starting with "connect:".

## Millisecond diff

When actively developing an application it can be useful to see when the time spent between one `debug()` call and the next. Suppose for example you invoke `debug()` before requesting a resource, and after as well, the "+NNNms" will show you how much time was spent between calls.

![](http://f.cl.ly/items/2i3h1d3t121M2Z1A3Q0N/Screenshot.png)

When stdout is not a TTY, `Date#toUTCString()` is used, making it more useful for logging the debug information as shown below:

![](http://f.cl.ly/items/112H3i0e0o0P0a2Q2r11/Screenshot.png)

## Debug Plus Author

- Elliot Chong

## Debug Authors

- TJ Holowaychuk
- Nathan Rajlich

## Debug & Debug Plus License

(The MIT License)

Original work Copyright (c) 2014 TJ Holowaychuk <tj@vision-media.ca>
Modified work Copyright (c) 2014 Elliot Chong <code@elliotjameschong.com>

	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	'Software'), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
