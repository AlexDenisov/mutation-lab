require './lib/models/mutation_result'
require './lib/models/execution_result'
require './lib/models/mutation_point'

require './lib/presenters/mutant_presenter'

RSpec.describe MutantPresenter do

  let(:passed_test) {
    result = ExecutionResult.new
    result.status = 2
    result
  }

  let(:failed_test) {
    result = ExecutionResult.new
    result.status = 1
    result
  }

  let(:survived_mutation_result) {
    result = MutationResult.new
    allow(result).to receive(:execution_result).and_return(passed_test)
    result
  }

  let(:killed_mutation_result) {
    result = MutationResult.new
    allow(result).to receive(:execution_result).and_return(failed_test)
    result
  }

  let(:mutation_results) {
    [ killed_mutation_result, survived_mutation_result, killed_mutation_result ]
  }

  let(:some_mutation_point) {
    point = MutationPoint.new

    point.unique_id = 'unique_identifier'
    point.filename = 'fooo.h'
    point.line_number = 42

    allow(point).to receive(:mutation_results).and_return(mutation_results)

    point
  }

  let(:weakly_killed) {
    point = MutationPoint.new

    mutation_results = [ survived_mutation_result, killed_mutation_result, survived_mutation_result ]

    allow(point).to receive(:mutation_results).and_return(mutation_results)

    point
  }

  let(:weakly_killed_mutant) { MutantPresenter.new(weakly_killed) }

  let(:strongly_killed) {
    point = MutationPoint.new

    mutation_results = [ killed_mutation_result, killed_mutation_result, killed_mutation_result ]

    allow(point).to receive(:mutation_results).and_return(mutation_results)

    point
  }
  let(:strongly_killed_mutant) { MutantPresenter.new(strongly_killed) }

  let(:survived) {
    point = MutationPoint.new

    mutation_results = [ survived_mutation_result, survived_mutation_result, survived_mutation_result ]

    allow(point).to receive(:mutation_results).and_return(mutation_results)

    point
  }
  let(:survived_mutant) { MutantPresenter.new(survived) }

  let(:mutant) { MutantPresenter.new(some_mutation_point) }

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

  it 'weakly_killed?' do
    expect(weakly_killed_mutant.killed?).to be_truthy
    expect(weakly_killed_mutant.weakly_killed?).to be_truthy
    expect(weakly_killed_mutant.strongly_killed?).to be_falsy
    expect(weakly_killed_mutant.survived?).to be_falsy
  end

  it 'strongly_killed?' do
    expect(strongly_killed_mutant.killed?).to be_truthy
    expect(strongly_killed_mutant.weakly_killed?).to be_falsy
    expect(strongly_killed_mutant.strongly_killed?).to be_truthy
    expect(strongly_killed_mutant.survived?).to be_falsy
  end

  it 'survived?' do
    expect(survived_mutant.killed?).to be_falsy
    expect(survived_mutant.weakly_killed?).to be_falsy
    expect(survived_mutant.strongly_killed?).to be_falsy
    expect(survived_mutant.survived?).to be_truthy
  end

end

