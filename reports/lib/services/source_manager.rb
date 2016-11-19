require 'rubygems'

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

