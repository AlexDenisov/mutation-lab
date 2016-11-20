require './lib/models/mutation_result'
require './lib/models/execution_result'
require './lib/models/mutation_point'
require './lib/presenters/mutant_presenter'

require './lib/presenters/report_presenter'

RSpec.describe ReportPresenter do

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

    point.unique_id = 'DAGDeltaAlgorithmTest_7bb5bd29b15632cb0483fd3edb4aff60_188_2_1_add_mutation_operator'
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

  let(:report) { ReportPresenter.new( [survived_mutant, weakly_killed_mutant, strongly_killed_mutant] ) }

  it 'killed_mutants_count' do
    expect(report.killed_mutants_count).to eq(2)
  end

  it 'survived_mutants_count' do
    expect(report.survived_mutants_count).to eq(1)
  end

  it 'weakly_killed_mutants_count' do
    expect(report.weakly_killed_mutants_count).to eq(1)
  end

  it 'strongly_killed_mutants_count' do
    expect(report.strongly_killed_mutants_count).to eq(1)
  end

  it 'mutation_score' do
    expect(report.mutation_score).to eq("67%")
  end

end

