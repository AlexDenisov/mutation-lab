require './lib/models/mutation_result'
require './lib/models/execution_result'
require './lib/models/mutation_point'

require './lib/presenters/mutant_presenter'

RSpec.describe MutantPresenter do

  let(:failed) {
    result = ExecutionResult.new
    result.status = 2
    result
  }

  let(:passed) {
    result = ExecutionResult.new
    result.status = 1
    result
  }

  let(:survived_mutation_result) {
    result = MutationResult.new
    allow(result).to receive(:execution_result).and_return(failed)
    result
  }

  let(:mutation_result) {
    result = MutationResult.new
    allow(result).to receive(:execution_result).and_return(passed)
    result
  }

  let(:mutation_results) {
    [ mutation_result, survived_mutation_result, mutation_result ]
  }

  let(:mutation_point) {
    point = MutationPoint.new

    point.unique_id = 'unique_identifier'
    point.filename = 'fooo.h'
    point.line_number = 42

    allow(point).to receive(:mutation_results).and_return(mutation_results)

    point
  }

  let(:mutant) { MutantPresenter.new(mutation_point) }

  it 'slug' do
    expect(mutant.slug).to match('unique_identifier')
  end

  it 'display_name' do
    expect(mutant.display_name).to match('unique_identifier')
  end

  it 'mutation_address' do
    expect(mutant.mutation_address).to match('fooo.h:42')
  end

  it 'total_tests_count' do
    expect(mutant.total_tests_count).to be_equal(3)
  end

  it 'failed_tests_count' do
    expect(mutant.failed_tests_count).to be_equal(2)
  end

  it 'summary' do
    expect(mutant.summary).to match("2/3")
  end

  it 'tests' do
    expect(mutant.tests.count).to be_equal(3)
  end


end

