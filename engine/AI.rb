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
  end

  class JuniorAlgorithm
    def initialize board
       @board = board
    end

    def decision
    end
  end
end
