require './lib/presenters/mutant_presenter'

class MutantSorter
  def sort(mutants)
    mutants.sort_by do |m|
      priority = 0
      priority = 1 if m.weakly_killed?
      priority = 2 if m.strongly_killed?

      [ priority, m.total_tests_count ]
    end
  end

end

