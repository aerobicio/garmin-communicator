# Garmin Communicator

[![Dependency Status](https://gemnasium.com/aerobicio/garmin-communicator.png)](https://gemnasium.com/aerobicio/garmin-communicator) [![Coverage Status](https://coveralls.io/repos/aerobicio/garmin-communicator/badge.png)](https://coveralls.io/r/aerobicio/garmin-communicator)

[![wercker status](https://app.wercker.com/status/b1a5d9088c0a82f7e9dfe9cdbe4f660b/m "wercker status")](https://app.wercker.com/project/bykey/b1a5d9088c0a82f7e9dfe9cdbe4f660b)

## A (more) sane re-write of the Garmin Device Connect JS library.

### Requirements

- `underscore` (http://underscorejs.org)
- `q` (https://github.com/kriskowal/q)

### Developing

##### Install developments tools:
- `npm install`
- `brew install fswatch terminal-notifier`

###### Watch files, recompile on change
- `make develop`

You can now either run the suite in-browser by opening `./spec/index.html`, or
just edit files, and the suite will be run whenever a spec or source file is
saved.

##### Run specs:
- `make lint`
- `make spec` or open `./spec/index.html` in a browser.
