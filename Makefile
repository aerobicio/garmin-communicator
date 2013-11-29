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
dist: concat minify

# uglify built code
minify:
	mkdir -p dist
	cp $(COMPILE)/src/index.js dist/garmin.js
	$(UGLIFYJS) dist/garmin.js --stats -o dist/garmin.min.js

# combine compiled code for production
concat:
	mkdir -p $(COMPILE)/{src,spec}
	$(BROWSERIFY) -t coffeeify --extension=".coffee" $(SRC)/*.coffee > $(COMPILE)/src/index.js
	$(BROWSERIFY) -t coffeeify --extension=".coffee" $(SPEC)/*.coffee > $(COMPILE)/spec/index.js

instrument_coverage:
	rm -rf coverage && mkdir coverage
	$(JSCOVERAGE) --no-highlight $(COMPILE)/src $(COMPILE)/src-cov
	rm -rf $(COMPILE)/src
	mv $(COMPILE)/src-cov $(COMPILE)/src

convert_coverage:
	sed -i.temp '/phantomjs/d' coverage/coverage.json
	cat coverage/coverage.json | grep --max-count=1 -e '"coverage":' | sed "s/[^0-9.]*//g" > coverage/covered_percent
	$(JSON2HTMLCOV) coverage/coverage.json > coverage/coverage.html

coverage: convert_coverage
	$(eval COVERED_PERCENT    := $(shell cat coverage/covered_percent))
	$(eval COVERAGE_THRESHOLD := $(shell cat .coverage))
	$(eval COVERAGE_PASSING   := $(shell node -pe "$(COVERED_PERCENT) >= $(COVERAGE_THRESHOLD)"))

	echo "$(COVERED_PERCENT) >= $(COVERAGE_THRESHOLD)"
	test "$(COVERAGE_PASSING)" = "true"

# run coffeelint over the source code
lint:
	$(COFFEELINT) -r src

# run the test suite
spec: clean concat instrument_coverage
	$(MOCHA_PHANTOMJS) --reporter json-cov spec/index.html > coverage/coverage.json

# watch for changes; rebuild, retest
develop:
	wachs -o "$(SRC)/**/*.coffee,$(SPEC)/**/*.html,$(SPEC)/**/*.coffee" "make clean concat instrument_coverage"

.PHONY: spec ci-spec dist clean instrument COVERAGE_THRESHOLD
