require 'rubygems'
require 'data_mapper'
require 'slim'
require 'uri'

def humanize_duration millis
  [[1000, :ms], [60, :s], [60, :m], [24, :h], [1000, :d]].map{ |count, name|
    if millis > 0
      millis, n = millis.divmod(count)
      "#{n.to_i}#{name}"
    end
  }.compact.reverse.join(' ')
end

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

  def killed?
    result.status.equal? 1
  end

  def survived?
    result.status.equal? 2
  end

  def timed_out?
    result.status.equal? 3
  end

  def crashed?
    result.status.equal? 4
  end

  def dryRun?
    result.status.equal? 5
  end

  def status
    case result.status
    when 1
      "Killed"
    when 2
      "Survived"
    when 3
      "Timed Out"
    when 4
      "Crashed"
    when 5
      "Dry Run"
    else
      "unknown"
    end
  end

  def duration
    humanize_duration result.duration
  end

  def source
    begin
    code = SourceManager.instance.source_for_file_at_line filename, line
    caret = " " * (column - 1)
    caret[column - 1] = "^"
    "#{code}#{caret}"
    rescue
      return "not_found"
    end
  end

  def stderr
    result.stderr
  end

  def stdout
    result.stdout
  end

  property :test_id, Integer
  property :mutation_distance, Integer
end

class ExecutionResult
  include DataMapper::Resource
  storage_names[:default] = "execution_result"
  property :rowid, Serial

  property :status, Integer
  property :duration, Integer
  property :stderr, String
  property :stdout, String
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
  property :rowid, Serial

  property :test_name,   String
  has n, :mutation_results, :child_key => [ :test_id ]

  belongs_to :execution_result, child_key: [ :execution_result_id ]

  def mutations_count
    @mutations_count ||= mutation_results.count
  end

  def mutations_duration
    duration = mutation_results.map(&:result).inject(0) { |sum, result| sum + result.duration}
    humanize_duration duration
  end

  def duration
    "#{execution_result.duration}ms"
  end

  def slug
    URI.escape(test_name)
  end

  def failed?
    execution_result.status.equal? 1
  end

  def passed?
    execution_result.status.equal? 2
  end

  def timed_out?
    execution_result.status.equal? 3
  end

  def crashed?
    execution_result.status.equal? 4
  end

  def stderr
    execution_result.stderr
  end

  def stdout
    execution_result.stdout
  end

  def status
    case execution_result.status
    when 1
      "Failed"
    when 2
      "Passed"
    when 3
      "Timed Out"
    when 4
      "Crashed"
    else
      "unknown"
    end
  end

end

DataMapper.finalize

class Context
  def tests
    @tests ||= Test.all
  end

  def mutants
    @mutants ||= MutationResult.all
  end

  def tests_count
    tests.count
  end

  def mutants_count(distance = nil)
    local = mutants
    local = local.all(:mutation_distance => distance) unless distance.nil?
    local.all().count
  end

  def filter_mutants(result, distance = nil)
    local = mutants
    local = local.all(:mutation_distance => distance) unless distance.nil?
    local.all(MutationResult.execution_result.status => result)
  end

  def killed_mutants_count(distance = nil)
    filter_mutants(1, distance).count
  end

  def survived_mutants_count(distance = nil)
    filter_mutants(2, distance).count
  end

  def timedout_mutants_count(distance = nil)
    filter_mutants(3, distance).count
  end

  def crashed_mutants_count(distance = nil)
    filter_mutants(4, distance).count
  end

  def mutation_score(distance = nil)
    non_survived_mutants = (crashed_mutants_count(distance) + killed_mutants_count(distance) + timedout_mutants_count(distance)) * 1.0
    (non_survived_mutants / mutants_count(distance) * 100).round(1)
  end

  def duration_at_distance(distance)
    duration = mutants.all(:mutation_distance => distance).map(&:result).inject(0) { |value, result| value + result.duration }
    humanize_duration duration
  end

  def execution_duration
    duration = ExecutionResult.all.sum(:duration)
    humanize_duration duration
  end

  def minimum_mutation_distance
    @mutants.min(:mutation_distance)
  end

  def maximum_mutation_distance
    @mutants.max(:mutation_distance)
  end

  def mean_mutation_distance
    @mutants.avg(:mutation_distance).round(0)
  end

end

report_path = $ARGV[0]
report_name = $ARGV[1]

DataMapper::Logger.new($stdout, :debug)
#DataMapper.setup(:default, "sqlite://#{Dir.pwd}/../llvm_reports/#{report}.sqlite")
DataMapper.setup(:default, "sqlite://#{report_path}")

layout = File.read("./layout/index.slim")
l = Slim::Template.new { layout }
html = l.render(Object.new, ctx: Context.new)

f = File.new("./build/#{report_name}.html", "w")
f.write(html)
f.close

