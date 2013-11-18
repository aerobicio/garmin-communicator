# Garmin Communicator [![wercker status](https://app.wercker.com/status/ff202c4e0f75411cda393cbc59e651b9 "wercker status")](https://app.wercker.com/project/bykey/ff202c4e0f75411cda393cbc59e651b9)

## A (more) sane re-write of the Garmin Device Connect JS library.

### Requirements

- `underscore` (http://underscorejs.org)
- `q` (https://github.com/kriskowal/q)

### Developing

##### Install developments tools:
- `npm install`
- `npm install wach` (platform dependant so this cannot be an npm dependancy)

###### Watch files, recompile on change
- `make develop`
- open `./spec/index.html`

##### Run specs:
- `make lint`
- `make spec` or open `./spec/index.html` in a browser.
