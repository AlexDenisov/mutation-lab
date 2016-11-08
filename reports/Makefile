.PHONY: build build/css

REPORT_NAME=$(shell basename $(REPORT) | cut -d"." -f1)

build/css:
	mkdir -p build/css
	cp -R layout/css/ build/css

build/js:
	mkdir -p build/js
	cp -R layout/js/ build/js

build/fonts:
	mkdir -p build/fonts
	cp -R layout/fonts/ build/fonts

build:
	bundle exec ruby render.rb $(REPORT) $(REPORT_NAME)
	open ./build/$(REPORT_NAME).html

clean:
	rm -rf build

