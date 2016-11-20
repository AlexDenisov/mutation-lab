require './lib/models/mutation_result'
require './lib/models/execution_result'
require './lib/models/mutation_point'
require './lib/presenters/mutant_presenter'

require './lib/services/mutant_sorter'

RSpec.describe MutantSorter do

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

  let(:sorter) { MutantSorter.new }

  it 'survived goes before weakly_killed' do
    actual = sorter.sort [ weakly_killed_mutant, survived_mutant ]
    expected = [ survived_mutant, weakly_killed_mutant ]

    expect(actual).to match_array(expected)
  end

  it 'survived goes before strongly_killed' do
    actual = sorter.sort [ strongly_killed_mutant, survived_mutant ]
    expected = [ survived_mutant, strongly_killed_mutant ]

    expect(actual).to match_array(expected)
  end

  it 'weakly_killed goes before strongly_killed' do
    actual = sorter.sort [ strongly_killed_mutant, weakly_killed_mutant ]
    expected = [ weakly_killed_mutant, strongly_killed_mutant ]

    expect(actual).to match_array(expected)
  end

  it 'survived then weakly_killed then strongly_killed' do
    actual = sorter.sort [ strongly_killed_mutant, survived_mutant, weakly_killed_mutant ]
    expected = [ survived_mutant, weakly_killed_mutant, strongly_killed_mutant ]

    expect(actual).to match_array(expected)
  end

end

