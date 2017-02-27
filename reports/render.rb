require 'rubygems'
require 'data_mapper'
require 'slim'
require 'uri'

require './lib/services/source_manager'
require './lib/services/mutant_sorter'

require './lib/models/config'
require './lib/models/execution_result'
require './lib/models/mutation_point'
require './lib/models/mutation_point_debug'
require './lib/models/mutation_result'
require './lib/models/test'

require './lib/presenters/mutant_presenter'
require './lib/presenters/report_presenter'

def humanize_duration millis
  [[1000, :ms], [60, :s], [60, :m], [24, :h], [1000, :d]].map { |count, name|
    if millis > 0
      millis, n = millis.divmod(count)
      "#{n.to_i}#{name}"
    end
  }.compact.reverse.join(' ')
end

DataMapper.finalize

class Context
  def initialize(mutants, config)
    @report = ReportPresenter.new(mutants)
    @config = config
  end

  def project_name
    return "" if @config.nil?
    @config.project_name
  end

  def report
    @report
  end

  def tests
    @tests ||= Test.all
  end

  def mutants
    @mutants ||= MutationResult.all
  end

  def mutation_points
    MutationPoint.all
  end

  def debug_mutation_points
    MutationPointDebug.all
  end

  def tests_count
    tests.count
  end

  def unique_mutants_count
    MutationPoint.all.count
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
    mutants.min(:mutation_distance)
  end

  def maximum_mutation_distance
    mutants.max(:mutation_distance)
  end

  def mean_mutation_distance
    mutants.avg(:mutation_distance).round(0)
  end

end

report_path = $ARGV[0]
report_name = $ARGV[1]

#DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite://#{report_path}")

def render(context, layout_name, output)
  layout = File.read("./layout/#{layout_name}.slim")
  l = Slim::Template.new { layout }
  html = l.render(Object.new, ctx: context)

  f = File.new("./build/#{output}.html", "w")
  f.write(html)
  f.close
end

mutants = MutationPoint.all.map { |mp|
  MutantPresenter.new(mp)
}

ctx = Context.new(mutants, MullConfig.first)

render ctx, "index", report_name
#render ctx, "debug", "#{report_name}_debug"

