COMPILE         = ./compile
SRC             = ./src
SPEC            = ./spec
DIST            = ./dist
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
	cp -R $(COMPILE)/src $(DIST)/src

browserify:
	mkdir -p $(DIST)
	$(BROWSERIFY) $(COMPILE)/src/garmin.js --outfile $(DIST)/garmin.js

browserify_specs:
	$(BROWSERIFY) $(COMPILE)/spec/*_spec.js --outfile $(COMPILE)/spec/index.js

# uglify built code
uglify:
	$(UGLIFYJS) $(DIST)/garmin.js --stats -o $(DIST)/garmin.min.js

# combine compiled code for production
compile:
	$(COFFEE) -m -o $(COMPILE)/src -c src
	$(COFFEE) -m -o $(COMPILE)/spec -c spec

# run coffeelint over the source code
lint:
	$(COFFEELINT) -r src

# run the test suite
spec: lint compile
	$(ISTANBUL) cover ./node_modules/mocha/bin/_mocha -- --ui bdd --require $(SPEC)/spec_helper.js --reporter spec $(COMPILE)/spec/*_spec.js
	$(ISTANBUL) check-coverage --statements 89 --branches 67 --functions 85 --lines 89

coverage_report:
	$(ISTANBUL) report

# watch for changes; rebuild, retest
develop:
	wachs -o "$(SRC)/**/*.coffee,$(SPEC)/**/*.html,$(SPEC)/**/*.coffee" "make clean compile browserify_specs"

.PHONY: spec ci-spec dist clean instrument compile
