COMPILE         = compile
SRC             = src
SPEC            = spec
BIN             = node_modules/.bin
ISTANBUL        = ./node_modules/istanbul/lib/cli.js
MOCHA           = ./node_modules/mocha/bin/_mocha
COFFEE          = ./node_modules/.bin/coffee
UGLIFYJS        = ./node_modules/.bin/uglifyjs
BROWSERIFY      = ./node_modules/.bin/browserify
COFFEELINT      = ./node_modules/.bin/coffeelint

# bootstrap the project for development
bootstrap:
	npm install --dev

# remove dist targets
clean:
	rm -f $(COMPILE)/{spec,src}/*.js $(COMPILE)/{spec,src}/*.map

# build dist targets
dist: compile browserify uglify
	mkdir -p dist
	cp $(COMPILE)/src/garmin*.js dist

browserify:
	$(BROWSERIFY) $(SRC)/*.js > $(COMPILE)/src/garmin.js

# uglify built code
uglify:
	$(UGLIFYJS) $(COMPILE)/src/garmin.js --stats -o dist/garmin.min.js

# combine compiled code for production
compile:
	coffee -m -o compile/src -c src
	coffee -m -o compile/spec -c spec

# run coffeelint over the source code
lint:
	$(COFFEELINT) -r src

# run the test suite
spec: lint compile
	istanbul cover ./node_modules/mocha/bin/_mocha -- --ui bdd --require spec/runner.js --reporter spec compile/spec/*_spec.js
	istanbul check-coverage --statements 89 --branches 67 --functions 85 --lines 89

coverage_report:
	istanbul report

# watch for changes; rebuild, retest
develop:
	wachs -o "$(SRC)/**/*.coffee,$(SPEC)/**/*.html,$(SPEC)/**/*.coffee" "make clean compile"

.PHONY: spec ci-spec dist clean instrument compile
