# Reference card for usual actions in development environment.
#
# For standard installation, see INSTALL.
# For details about development environment, see CONTRIBUTING.rst.
#

# Directories.
BASEDIR = $(CURDIR)
BINDIR ?= $(CURDIR)/bin
INPUTDIR = $(BASEDIR)/content
OUTPUTDIR = $(BASEDIR)/public
CONFFILE = $(BASEDIR)/pelicanconf.py
PUBLISHCONF = $(BASEDIR)/publishconf.py

# Executables.
BOWER ?= $(shell npm bin)/bower
BUNDLE_INSTALL ?= BUNDLE_BIN=$(BINDIR) bundle install --path=$(BASEDIR)/lib
GHP ?= ghp-import
GORUN ?= gorun.py
NPM ?= npm
PELICAN ?= pelican
PELICANOPTS =
PIP ?= pip
PY ?= python
SASS ?= $(BINDIR)/sass
UGLIFYJS ?= $(shell npm bin)/uglifyjs


#: help - Display available targets.
.PHONY: help
help:
	@echo "Reference card for usual actions in development environment."
	@echo "Here are available targets:"
	@egrep -o "^#: (.+)" [Mm]akefile  | sed 's/#: /* /'


#: develop - Install development libraries.
.PHONY: develop
develop:
	$(BUNDLE_INSTALL)
	$(NPM) install
	$(BOWER) install
	$(PIP) install -r requirements.pip


#: bower - Download libraries with bower.
.PHONY: bower
bower: develop
	$(BOWER) install


#: watch - Watch in-development files and automatically build them on update.
.PHONY: watch
watch: develop
	$(GORUN)


#: html - Generate HTML files in public/ folder.
.PHONY: html
html:
	mkdir -p content
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)


#: css - Generate CSS files in public/ folder.
.PHONY: css
css:
	mkdir -p public/css
	$(SASS) assets/css/main.scss public/css/main.css


#: jslibs - Generate JS libraries in public/ folder.
.PHONY: js
js:
	mkdir -p public/js
	$(UGLIFYJS) \
		bower_components/jquery/dist/jquery.js \
		bower_components/tether/dist/js/tether.js \
		bower_components/bootstrap/dist/js/bootstrap.js \
		--output=public/js/libs.min.js
	$(UGLIFYJS) \
		assets/js/main.js \
		--output=public/js/main.js


#: img - Generate public/img/
.PHONY: img
img:
	mkdir -p public/img
	rsync -r --progress assets/img/ public/img/


#: fonts - Generate public/fonts/
.PHONY: fonts
fonts:
	mkdir -p public/fonts
	rsync --progress bower_components/fontawesome/fonts/* public/fonts/
	rsync -r --progress assets/fonts/ public/fonts/


#: public - Generate public/ folder contents.
.PHONY: public
public: css fonts html img js


#: serve - Serve public/ folder on localhost:8000
.PHONY: serve
serve:
	cd public/ && python -m SimpleHTTPServer


#: clean - Basic cleanup, mostly temporary files.
.PHONY: clean
clean:


#: distclean - Remove local builds
.PHONY: dist-clean
dist-clean: clean
	rm -rf public/
	rm -rf bower_components/


#: maintainer-clean - Remove almost everything that can be re-generated.
.PHONY: maintainer-clean
maintainer-clean: dist-clean
	rm -rf node_modules/


#: gh-pages-commit - Commit generated website into gh-pages branch.
.PHONY: gh-pages-commit
gh-pages-commit:
	cp CNAME public/
	$(GHP) -n public/


# gh-pages-push - Travis pushes gh-pages branch on Github.
.PHONY: gh-pages-push
gh-pages-push:
	@git push -fq https://${GH_TOKEN}@github.com/$(TRAVIS_REPO_SLUG).git gh-pages > /dev/null
