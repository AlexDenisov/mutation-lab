require 'rubygems'
require 'data_mapper'

class MullConfig
  include DataMapper::Resource
  storage_names[:default] = "config"
  property :rowid, Serial

  property :project_name, String
end


