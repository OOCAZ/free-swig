SHA := $(shell git rev-parse HEAD)
THIS_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
VERSION_REGEX = [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*[^\" ]*
VERSION := $(shell cat package.json | jq -r .version)

TMP = 'tmp'
REMOTE = origin
BRANCH = gh-pages
BIN = node_modules/.bin
PWD = $(shell pwd | sed -e 's/[\/&]/\\&/g')

all:
	@echo "Installing packages"
	@yarn install --depth=100 --loglevel=error
	@yarn link &>/dev/null

browser/comments.js: FORCE
	@sed -i.bak 's/v${VERSION_REGEX}/v${VERSION}/' $@
	@rm $@.bak

.SECONDARY dist/swig.js: \
	browser/comments.js

.SECONDARY dist/swig.min.js: \
	dist/swig.js

.INTERMEDIATE browser/test/tests.js: \
	tests/comments.test.js \
	tests/filters.test.js \
	tests/tags.test.js \
	tests/variables.test.js \
	tests/tags/autoescape.test.js \
	tests/tags/else.test.js \
	tests/tags/filter.test.js \
	tests/tags/for.test.js \
	tests/tags/if.test.js \
	tests/tags/macro.test.js \
	tests/tags/raw.test.js \
	tests/tags/set.test.js \
	tests/tags/spaceless.test.js \
	tests/basic.test.js

clean: FORCE
	@rm -rf dist
	@rm -rf ${TMP}

build: clean dist dist/swig.min.js
	@echo "Built to ./dist/"

dist:
	@mkdir -p $@

dist/swig.js:
	@echo "Building $@..."
	@cat $^ > $@
	@${BIN}/browserify browser/index.js >> $@

dist/swig.min.js:
	@echo "Building $@..."
	@${BIN}/uglifyjs $^ --comments -c warnings=false -m --source-map dist/swig.js.map > $@

browser/test/tests.js:
	@echo "Building $@..."
	@cat $^ > tests/browser.js
	@perl -pi -e 's/\.\.\/\.\.\/lib/\.\.\/lib/g' tests/browser.js
	@${BIN}/browserify tests/browser.js > $@
	@rm tests/browser.js

tests := $(shell find ./tests -name '*.test.js' ! -path "*node_modules/*")
reporter = dot
opts =
test:
	@${BIN}/mocha --check-leaks --reporter ${reporter} ${opts} ${tests}

test-browser: FORCE clean browser/test/tests.js
	${BIN}/mocha-chrome browser/test/index.html --reporter ${reporter}

out = tests/coverage.html
cov-reporter = html-cov
coverage:
ifeq (${cov-reporter}, travis-cov)
	@${BIN}/mocha ${opts} ${tests} --require blanket -R ${cov-reporter}
else
	@echo "@${BIN}/mocha ${opts} ${tests} --require blanket -R ${cov-reporter} > ${out}"
	@${BIN}/mocha ${opts} ${tests} --require blanket -R ${cov-reporter} > ${out}
	@sed -i .bak -e "s/${PWD}//g" ${out}
	@rm ${out}.bak
	@echo
	@echo "Built Report to ${out}"
	@echo
endif

docs/coverage.html: FORCE
	@echo "Building $@..."
	@make coverage out=$@

gh-pages: clean build build-docs
	@mkdir -p ${TMP}/js
	@mkdir -p docs/css
	@rm -f docs/coverage.html
	@${BIN}/lessc --yui-compress --include-path=docs/less docs/less/swig.less docs/css/swig.css
	@${BIN}/still docs -o ${TMP} -i "layout" -i "json" -i "less" -v
	@make coverage out=${TMP}/coverage.html
	@cp dist/swig.* ${TMP}/js/
	@git checkout ${BRANCH}
	@cp -r ${TMP}/* ./
	@rm -rf ${TMP}
ifeq (${THIS_BRANCH}, master)
	@git add .
	@git commit -n -am "Automated build from ${SHA}"
	@git push ${REMOTE} ${BRANCH}
	@git checkout ${THIS_BRANCH}
	@git clean -f -d docs/
endif

FORCE:

.PHONY: all version \
	build build-docs \
	test test-browser lint coverage \
	docs gh-pages
