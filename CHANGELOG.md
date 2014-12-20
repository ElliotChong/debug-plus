<a name="1.1.0"></a>
## 1.1.0 (2014-12-20)


#### Features

* CoffeeScript is now a development-only dependency ([65691521](https://github.com/ElliotChong/debug-plus/commit/6569152178418b594b26c8673ce850c9f5f25a22))


<a name="1.0.1"></a>
### 1.0.1 (2014-12-20)

#### Bug Fixes

* Adding CoffeeScript as a dependency  ([a3d93882](https://github.com/ElliotChong/debug-plus/commit/a3d93882220c25bad01a355ba5aa0c0885ff4919))

## 1.0.0 (2014-12-19)

Initial public release.

#### Features

* Backwards-compatible with the standard `debug` module
* Support for `console`-style `log`, `warn`, `error`, and `dir` methods
* Adds `timestamp`, `stringify`, `inspect` helper methods to aid in debugging
* Cache-backed instantiation that treats keys as global for the application
* Efficient lazy-instantiation using run-once `Object.defineProperty` getters
