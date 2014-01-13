class AI
  def initialize board, difficulty=:hard
    @board      = board
    @difficulty = difficulty
  end

  def moves
    if difficulty == :hard
      MasterAlgorithm.new(@board).decision
    else
      JuniorAlgorithm.new(@board).decision
    end
  end

  class MasterAlgorithm
    def initialize board
      @board = board
    end

    def decision
    end

    private

    # function that takes exactly specific count of rubies
    # function that takes random number of rubies
    # function that calculates the num sum
    # function that check if only single matches + bigget stack are available
    def nim_sum(*stacks)
      stacks.inject(&:^)
    end

    def break_stacks_in_power_of_twos
    end

    def power_of_2?(number)
      number.to_s(2).scan(/1/).size == 1
    end
  end

  class JuniorAlgorithm
    def initialize board
       @board = board
    end

    def decision
    end
  end
end
