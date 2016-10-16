require 'rubygems'
require 'slim'
require 'uri'

class Test
  attr_accessor :name
  attr_accessor :mutations_count
  attr_accessor :content

  def slug
    URI.escape(name)
  end
end

layout = File.read("./layout/index.slim")

l = Slim::Template.new { layout }

tests = []

5.times do |idx|
  t = Test.new
  t.name = "test #{idx}"
  t.mutations_count = Random.rand(142)
  t.content = "Wrap buttons or secondary text in .panel-footer. Note that panel footers do not inherit colors and borders when using contextual variations as they are not meant to be in the foreground."

  tests << t
end

html = l.render(Object.new, tests: tests)

puts html

f = File.new("./build/index.html", "w")
f.write(html)
f.close

