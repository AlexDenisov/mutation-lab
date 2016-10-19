.PHONY: build

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
	bundle exec ruby render.rb $(REPORT)
	open ./build/$(REPORT).html

clean:
	rm -rf build

