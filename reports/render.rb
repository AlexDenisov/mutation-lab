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
DataMapper.setup(:default, "sqlite://#{Dir.pwd}/ADTTests.db")

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

  def column
    number = point.column_number
    return 1 if number == 0
    number
  end

  def passed?
    result.status.equal? 2
  end

  def failed?
    result.status.equal? 1
  end

  def crashed?
    result.status.equal? 4
  end

  def timed_out?
    result.status.equal? 3
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
    code = SourceManager.instance.source_for_file_at_line filename, line
    caret = " " * (column - 1)
    caret[column - 1] = "^"
    "#{code}#{caret}"
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
  property :column_number, Integer
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

class Context
  def initialize
    @tests = Test.all
    @mutants = MutationResult.all
  end

  def tests
    @tests
  end

  def mutants
    @mutants
  end

  def tests_count
    tests.count
  end

  def mutants_count
    mutants.count
  end

end

layout = File.read("./layout/index.slim")
l = Slim::Template.new { layout }
html = l.render(Object.new, ctx: Context.new)

f = File.new("./build/index.html", "w")
f.write(html)
f.close

