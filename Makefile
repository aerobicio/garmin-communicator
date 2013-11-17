COMPILE=compile
SRC=src
SPEC=spec
BIN=node_modules/.bin
ISTANBUL=./node_modules/istanbul/lib/cli.js
MOCHA=./node_modules/mocha/bin/_mocha
COFFEE=./node_modules/.bin/coffee
UGLIFYJS=./node_modules/.bin/uglifyjs
BROWSERIFY=./node_modules/.bin/browserify
COFFEELINT=./node_modules/.bin/coffeelint
MOCHA_PHANTOMJS=./node_modules/.bin/mocha-phantomjs

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
	$(UGLIFYJS) garmin.js -o garmin.min.js

# combine compiled code for production
concat:
	$(BROWSERIFY) $(COMPILE)/src/*.js -o $(COMPILE)/src/index.js
	$(BROWSERIFY) $(COMPILE)/spec/*.js -o $(COMPILE)/spec/index.js

compile: clean
	$(COFFEE) --map --compile --output $(COMPILE)/src src/
	$(COFFEE) --map --compile --output $(COMPILE)/spec spec/

# run coffeelint over the source code
lint:
	$(COFFEELINT) -r src

# run the test suite
spec: clean lint compile concat
	$(MOCHA_PHANTOMJS) spec/index.html

# watch for changes; rebuild, retest
develop:
	wachs -o "$(SRC)/**/*.coffee,$(SPEC)/**/*.html,$(SPEC)/**/*.coffee" "make clean compile concat"

# run a benchmark against a known fixture file
benchmark:

.PHONY: compile spec ci-spec build clean instrument
