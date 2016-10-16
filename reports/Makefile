.PHONY: build

build:
	mkdir -p build/css
	cp -R layout/css/ build/css
	mkdir -p build/js
	cp -R layout/js/ build/js
	bundle exec ruby render.rb
	open ./build/index.html

clean:
	rm -rf build

