require 'rubygems'
require 'data_mapper'

class MutationResult
  include DataMapper::Resource
  storage_names[:default] = "mutation_result"
  property :rowid, Serial

  property :test_id, String
  property :mutation_distance, Integer
  property :mutation_point_id, String
  property :__tmp_caller_path, String

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

  def caller_path
    __tmp_caller_path
  end

  def caller_path_source_code
    caller_path.split("\n").map do |path|
      components = path.split(':')
      filename = components.first
      line = components.last.to_i

      space_count = filename.count(' ')
      filename.strip!
      begin
      code = SourceManager.instance.source_for_file_at_line filename, line
      pad = " " * space_count
      "#{pad}#{code.lstrip}"
      rescue
        "not_found"
      end
    end.join
  end

  def stderr
    result.stderr
  end

  def stdout
    result.stdout
  end

end

