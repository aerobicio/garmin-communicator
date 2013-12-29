COMPILE         = ./compile
SRC             = ./src
SPEC            = ./spec
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

browserify:
	$(BROWSERIFY) $(COMPILE)/src/garmin.js --outfile garmin.js

browserify_specs:
	$(BROWSERIFY) $(COMPILE)/spec/*_spec.js $(COMPILE)/spec/device/*_spec.js $(COMPILE)/spec/utils/*_spec.js $(COMPILE)/spec/workouts/*_spec.js --outfile $(COMPILE)/spec/index.js

# uglify built code
uglify:
	$(UGLIFYJS) garmin.js --stats -o garmin.min.js

# combine compiled code for production
compile:
	$(COFFEE) -m -o $(COMPILE)/src/ -c src
	$(COFFEE) -m -o $(COMPILE)/spec/ -c spec

# run coffeelint over the source code
lint:
	$(COFFEELINT) -r src

# run the test suite
spec: lint compile browserify_specs
	$(ISTANBUL) cover -x "**/spec/**" ./node_modules/mocha/bin/_mocha -- --growl --ui bdd --require $(SPEC)/spec_helper.js --reporter spec "$(COMPILE)/spec/**/*_spec.js"
	$(ISTANBUL) check-coverage --statements 85 --branches 70 --functions 81 --lines 86
	terminal-notifier -title 'Coverage Failing' -message 'Check your Apple stock!'

coverage_report:
	$(ISTANBUL) report

# watch for changes; rebuild, retest
develop:
	fswatch $(SRC):$(SPEC) "make spec &"

.PHONY: spec ci-spec dist clean instrument compile
