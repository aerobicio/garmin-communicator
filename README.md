# Garmin Communicator

[![Dependency Status](https://gemnasium.com/aerobicio/garmin-communicator.png)](https://gemnasium.com/aerobicio/garmin-communicator) [![Coverage Status](https://coveralls.io/repos/aerobicio/garmin-communicator/badge.png)](https://coveralls.io/r/aerobicio/garmin-communicator) [![wercker status](https://app.wercker.com/status/b1a5d9088c0a82f7e9dfe9cdbe4f660b/m "wercker status")](https://app.wercker.com/project/bykey/b1a5d9088c0a82f7e9dfe9cdbe4f660b)

***

## A sane re-write of the Garmin Device Connect JS library.
This project is a re-implementation of the official Garmin Communicator Device Connect Javascript API. It is intended as a replacement for the (seemingly) unmaintained official project.

It should be considered a __work in progress__, and is by no means a full re-implementation, and probably never will be. :)

### Runtime Dependancies
- `lodash` (http://lodash.com)
- `Q` (https://github.com/kriskowal/q)

### Developing
##### Install developments tools:
- `./script/bootstrap`

###### Watch files, recompile on change
- `gulp develop`

##### Running specs:
- `gulp spec`
