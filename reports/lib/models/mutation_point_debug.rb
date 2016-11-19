require 'rubygems'
require 'data_mapper'

class MutationPointDebug
  include DataMapper::Resource
  storage_names[:default] = "mutation_point_debug"
  property :rowid, Serial

  property :function, String
  property :basic_block, String
  property :instruction, String
  property :unique_id, String

  property :filename, String
  property :line_number, Integer
  property :column_number, Integer

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

end

