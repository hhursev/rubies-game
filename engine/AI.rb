require_relative 'board'

class AI
  attr_reader :rubies_board, :difficulty

  def initialize(rubies_board, difficulty=:hard)
    @difficulty   = difficulty
    @rubies_board = rubies_board
  end

  def moves
    if @difficulty == :hard
      MasterAlgorithm.new(@rubies_board).decision
    else
      JuniorAlgorithm.new(@rubies_board).decision
    end
  end

  class BaseAlgorithmFunctionality
    def initialize(rubies_board)
      @rubies_board = rubies_board
    end

    def stacks
      @rubies_board.board.keys.sort.group_by(&:first).values().map do |row|
        row.map { |row, column| @rubies_board.filled_at? row, column }
           .slice_before(false).map { |slice| slice.count(true) }
      end.flatten.reject { |stack| stack.zero? }
    end

    def nim_sum_zero?
      stacks.inject(&:^).zero? ? true : false
    end
  end

  class MasterAlgorithm < BaseAlgorithmFunctionality
    def decision
    end
  end

  class JuniorAlgorithm < BaseAlgorithmFunctionality
    def decision
    end
  end
end
