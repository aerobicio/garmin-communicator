COMPILE=compile
SRC=src
SPEC=spec
BIN=node_modules/.bin
ISTANBUL=./node_modules/istanbul/lib/cli.js
MOCHA=./node_modules/mocha/bin/_mocha

# bootstrap the project for development
bootstrap:
	npm install --dev

# remove dist targets
clean:
	rm -f $(COMPILE)/{spec,src}/*.js $(COMPILE)/{spec,src}/*.map

# build dist targets
build: compile concat minify

# uglify built code
minify:
	uglifyjs garmin.js -o garmin.min.js

# combine compiled code for production
concat:
	browserify $(COMPILE)/src/*.js -o $(COMPILE)/src/index.js
	browserify $(COMPILE)/spec//*.js -o $(COMPILE)/spec/index.js

compile: clean
	coffee --map --compile --output $(COMPILE)/src src/
	coffee --map --compile --output $(COMPILE)/spec spec/

# run coffeelint over the source code
lint:
	coffeelint -r src

# run the test suite
spec: clean compile concat
	# $(ISTANBUL) cover $(MOCHA) -- --growl --ui bdd --reporter spec --require compile/spec/spec_helper.js compile/spec/**/*_spec.js
	mocha-phantomjs spec/index.html

# watch for changes; rebuild, retest
develop:
	wachs -o "$(SRC)/**/*.coffee,$(SPEC)/**/*.html,$(SPEC)/**/*.coffee" "make clean compile concat"

# run a benchmark against a known fixture file
benchmark:

.PHONY: compile spec build clean instrument
