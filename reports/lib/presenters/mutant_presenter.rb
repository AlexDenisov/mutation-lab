require './lib/services/source_manager'

class MutantPresenter
  def initialize(point)
    @tests = point.mutation_results
    @total_tests_count = @tests.count
    @failed_tests_count = @total_tests_count - @tests.select(&:survived?).count
    @mutation_point = point
  end

  def slug
    @mutation_point.unique_id
  end

  def total_tests_count
    @total_tests_count
  end

  def failed_tests_count
    @failed_tests_count
  end

  def display_name
    chunks = @mutation_point.unique_id.split '_'
    chunks.delete_at(1)
    chunks.join '_'
  end

  def summary
    "#{@failed_tests_count}/#{@total_tests_count}"
  end

  def mutation_address
    "#{@mutation_point.filename}:#{@mutation_point.line_number}"
  end

  def call_path
    @mutation_point.__tmp_caller_path
  end

  def test_names
    @tests.map(&:test_id).join("\n")
  end

  def operator
    @mutation_point.mutation_operator
  end

  def source
    begin
    code = SourceManager.instance.source_for_file_at_line @mutation_point.filename, @mutation_point.line_number
    caret = " " * (@mutation_point.column_number - 1)
    caret[@mutation_point.column_number - 1] = "^"
    "#{code}#{caret}"
    rescue Exception => e
      return "not_found #{e}"
    end
  end

  def tests
    @tests
  end

  def killed?
    @failed_tests_count != 0
  end

  def survived?
    @failed_tests_count == 0
  end

  def weakly_killed?
    killed? && @failed_tests_count != @total_tests_count
  end

  def strongly_killed?
    killed? && @failed_tests_count == @total_tests_count
  end

  def to_s
    s = survived? ? 1 : 0
    wk = weakly_killed? ? 1 : 0
    sk = strongly_killed? ? 1 : 0

    "{#{s}#{wk}#{sk}}"
  end

  def inspect
    to_s
  end

end

