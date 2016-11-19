require 'rubygems'
require 'data_mapper'

class ExecutionResult
  include DataMapper::Resource
  storage_names[:default] = "execution_result"
  property :rowid, Serial

  property :status, Integer
  property :duration, Integer
  property :stderr, String
  property :stdout, String
end

