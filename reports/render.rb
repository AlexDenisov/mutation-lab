require 'rubygems'
require 'data_mapper'
require 'slim'
require 'uri'

class SourceManager
  def initialize
    @files = Hash.new
  end

  def source_for_file_at_line(filename, line)
    file = get_file(filename)
    get_line(file, line)
  end

  @@instance = SourceManager.new

  def self.instance
    return @@instance
  end

private
  def get_file(filename)
    File.open(filename, "r")
  end

  def get_line(file, line)
    file.readlines[line - 1]
  end
end

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite://#{Dir.pwd}/report_full.db")

class MutationResult
  include DataMapper::Resource
  storage_names[:default] = "mutation_result"
  property :rowid, Serial

  belongs_to :mutation_point, child_key: [ :mutation_point_id ]
  def point
    @mutation_point ||= mutation_point
  end

  belongs_to :execution_result, child_key: [ :execution_result_id ]
  def result
    @execution_result ||= execution_result
  end

  def filename
    point.filename
  end

  def line
    point.line_number
  end

  def status
    case result.status
    when 1
      "Failed"
    when 2
      "Passed"
    when 3
      "Timedout"
    when 4
      "Crashed"
    else
      "unknown"
    end
  end

  def duration
    "#{result.duration}ns"
  end

  def source
    SourceManager.instance.source_for_file_at_line filename, line
  end

  property :test_id, Integer
end

class ExecutionResult
  include DataMapper::Resource
  storage_names[:default] = "execution_result"
  property :rowid, Serial

  property :status, Integer
  property :duration, Integer
end

class MutationPoint
  include DataMapper::Resource
  storage_names[:default] = "mutation_point"
  property :rowid, Serial

  property :mutation_operator, String
  property :module_name, String
  property :filename, String
  property :line_number, Integer
end

class Test
  include DataMapper::Resource
  storage_names[:default] = 'test'
  property :rowid,  Serial

  property :test_name,   String
  has n, :mutation_results, :child_key => [ :test_id ]

  def mutations_count
    @mutations_count ||= mutation_results.count
  end

  def slug
    URI.escape(test_name)
  end
end

DataMapper.finalize

layout = File.read("./layout/index.slim")

l = Slim::Template.new { layout }

tests = Test.all

html = l.render(Object.new, tests: tests)

f = File.new("./build/index.html", "w")
f.write(html)
f.close

