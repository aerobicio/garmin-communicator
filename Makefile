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
MOCHA_PHANTOMJS = ./node_modules/.bin/mocha-phantomjs
JSCOVERAGE      = ./node_modules/.bin/jscoverage
JSON2HTMLCOV    = ./node_modules/.bin/json2htmlcov

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
	cp $(COMPILE)/src/index.js garmin.js
	$(UGLIFYJS) garmin.js -o garmin.min.js

# combine compiled code for production
concat:
	$(BROWSERIFY) $(COMPILE)/src/*.js -o $(COMPILE)/src/index.js
	$(BROWSERIFY) $(COMPILE)/spec/*.js -o $(COMPILE)/spec/index.js

compile: clean
	$(COFFEE) --map --compile --output $(COMPILE)/src src/
	$(COFFEE) --map --compile --output $(COMPILE)/spec spec/

instrument_coverage:
	rm -rf coverage && mkdir coverage
	$(JSCOVERAGE) --no-highlight $(COMPILE)/src $(COMPILE)/src-cov
	rm -rf $(COMPILE)/src
	mv $(COMPILE)/src-cov $(COMPILE)/src

convert_coverage:
	sed -i.temp '/phantomjs/d' coverage/coverage.json
	cat coverage/coverage.json | grep --max-count=1 -e '"coverage":' | sed "s/[^0-9.]*//g" > coverage/covered_percent
	cat coverage/coverage.json | $(JSON2HTMLCOV) > coverage/coverage.html

check_coverage: convert_coverage
	$(eval COVERAGE_PASSING := $(shell node -pe "$(shell cat coverage/covered_percent) >= $(shell cat .coverage)"))
	test "$(COVERAGE_PASSING)" == "true"

# run coffeelint over the source code
lint:
	$(COFFEELINT) -r src

# run the test suite
spec: clean compile instrument_coverage concat
	$(MOCHA_PHANTOMJS) --reporter json-cov spec/index.html > coverage/coverage.json

# watch for changes; rebuild, retest
develop:
	wachs -o "$(SRC)/**/*.coffee,$(SPEC)/**/*.html,$(SPEC)/**/*.coffee" "make clean compile instrument_coverage concat"

# run a benchmark against a known fixture file
benchmark:

.PHONY: compile spec ci-spec build clean instrument check_coverage
