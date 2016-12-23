require 'rubygems'
require 'data_mapper'

class MutationPoint
  include DataMapper::Resource
  storage_names[:default] = "mutation_point"
  property :rowid, Serial

  property :mutation_operator, String
  property :module_name, String
  property :filename, String
  property :line_number, Integer
  property :column_number, Integer
  property :unique_id, String
  property :__tmp_caller_path, String

  has n, :mutation_results, :child_key => [ :mutation_point_id ], :parent_key => [ :unique_id ]

end

