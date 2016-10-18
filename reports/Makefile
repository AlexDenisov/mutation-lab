.PHONY: build

build:
	mkdir -p build/css
	cp -R layout/css/ build/css
	mkdir -p build/js
	cp -R layout/js/ build/js
	mkdir -p build/fonts
	cp -R layout/fonts/ build/fonts
	bundle exec ruby render.rb
	open ./build/index.html

clean:
	rm -rf build

