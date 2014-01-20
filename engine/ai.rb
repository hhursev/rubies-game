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
end

class AI
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

    def random_take
      rubies_to_take = rand(1..stacks.max)
      take rubies_to_take, stacks.keep_if { |stack| stack >= rubies_to_take }.sample()
    end

    def single_rubies_with_stack
      take (stacks.size.even? ? stacks.max : stacks.max - 1), stacks.max
    end

    def take(rubies_count, from_stack_sized)
      row, column = locate_stack(from_stack_sized)
      0.upto(rubies_count - 1).map { |x| [row, column - x] }
    end

    def locate_stack(stack_size)
      @rubies_board.board.keys.sort.group_by(&:first).values().map do |row|
        connected_rubies = 0
        row.map do |row, column|
          @rubies_board.filled_at?(row, column) ? connected_rubies += 1 : connected_rubies = 0
          if connected_rubies == stack_size and not @rubies_board.filled_at?(row, column + 1)
            return [row, column]
          end
        end
      end
    end
  end

  class MasterAlgorithm < BaseAlgorithmFunctionality
    def decision
      return single_rubies_with_stack if stacks.count(1).eql?(stacks.size - 1)
      return random_take              if nim_sum_zero?
      return perfect_move
    end

    def nim_sum_zero?
      stacks.reduce(&:^).zero? ? true : false
    end

    def perfect_move
      take(*how_many_rubies_from_which_stack)
    end

    def how_many_rubies_from_which_stack
      altered_stacks = stacks.sort.reverse
      altered_stacks.each_with_index do |stack, index|
        1.upto(stack).each do |rubies|
          altered_stacks[index] -= rubies
          return [rubies, altered_stacks[index] + rubies] if altered_stacks.reduce(&:^).zero?
          altered_stacks[index] += rubies
        end
      end
    end
  end

  class JuniorAlgorithm < BaseAlgorithmFunctionality
    def decision
      if stacks.count(1).eql?(stacks.size - 1)
        single_rubies_with_stack
      else
        random_take
      end
    end
  end
end
