require 'rubygems'
require 'data_mapper'

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

