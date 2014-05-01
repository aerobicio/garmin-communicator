# Garmin Communicator

[![wercker status](https://app.wercker.com/status/b1a5d9088c0a82f7e9dfe9cdbe4f660b/s/master "wercker status")](https://app.wercker.com/project/bykey/b1a5d9088c0a82f7e9dfe9cdbe4f660b) [![Coverage Status](https://coveralls.io/repos/aerobicio/garmin-communicator/badge.png)](https://coveralls.io/r/aerobicio/garmin-communicator) [![Dependency Status](https://gemnasium.com/aerobicio/garmin-communicator.png)](https://gemnasium.com/aerobicio/garmin-communicator)

## A sane re-write of the Garmin Device Connect JS library.
This project is a re-implementation of the official [Garmin Communicator Device Connect Javascript API](http://developer.garmin.com/web/communicator-api/documentation/index.html), specifically it is an alternative to `Garmin.DevicePlugin`. It is intended as a replacement for the (seemingly) unmaintained official project.

It should be considered a __work in progress__, and is by no means a full re-implementation, and probably never will be. Currently only reading operations are supported, but support for writing is planned.

The main goal is to provide a better interface for interacting with Garmin devices via the Communicator Browser plugin.

### Why?

- No Prototype.js
- A promise based approach to async operations, no more insane polling!
- Tests!

***

### Runtime Dependencies
- `lodash` (http://lodash.com)
- `Q` (https://github.com/kriskowal/q)

### Developing
##### Install developments tools:
- `./script/bootstrap`

###### Watch files, recompile on change
- `gulp develop`

##### Running specs:
- `gulp spec`
