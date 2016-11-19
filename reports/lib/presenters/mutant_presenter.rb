require './lib/services/source_manager.rb'

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
    @mutation_point.unique_id
  end

  def summary
    "#{@failed_tests_count}/#{@total_tests_count}"
  end

  def mutation_address
    "#{@mutation_point.filename}:#{@mutation_point.line_number}"
  end

  def source
    begin
    code = SourceManager.instance.source_for_file_at_line filename, line_number
    caret = " " * (column_number - 1)
    caret[column_number - 1] = "^"
    "#{code}#{caret}"
    rescue
      return "not_found"
    end
  end

  def tests
    @tests
  end
end

