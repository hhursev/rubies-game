require_relative "./game_api"

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
    include RubiesGameAPI

    def initialize(rubies_board)
      @rubies_board = rubies_board
    end

    def stacks
      board = array_representation_of @rubies_board
      board.flat_map { |row| [0] + row }
           .chunk    { |elem| elem.eql? 1 }
           .map      { |from_ones, seq| seq.size if from_ones }
           .compact
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
      1.upto(rubies_count).map { |x| [row, column + x] }
    end

    def locate_stack(stack_size)
      @rubies_board.board.keys.sort.group_by(&:first).values().map do |row|
        connected_rubies = 0
        row.map do |row, column|
          @rubies_board.filled_at?(row, column) ? connected_rubies += 1 : connected_rubies = 0
          if connected_rubies == stack_size and not @rubies_board.filled_at?(row, column + 1)
            return [row, column - stack_size]
          end
        end
      end
    end

    def single_big_stack?
      stacks.count(1).eql?(stacks.size - 1)
    end
  end

  class MasterAlgorithm < BaseAlgorithmFunctionality
    def decision
      return single_rubies_with_stack if single_big_stack?
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
      if single_big_stack?
        single_rubies_with_stack
      else
        random_take
      end
    end
  end
end
