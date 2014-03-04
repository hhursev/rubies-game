class RubiesGame
  attr_reader :board, :first_player, :second_player, :ai_difficulty, :last_move

  def initialize(board, first_player, second_player, ai_difficulty=nil)
    @board         = board
    @first_player  = first_player
    @second_player = second_player
    @ai_difficulty = ai_difficulty
    @last_move     = ""
    @on_turn       = [@first_player, @second_player]
  end

  def winner
    @on_turn.first if @board.empty?
  end

  def on_move_is
    @on_turn.first
  end

  def make_move(these)
    begin
      @board.take_out(*these)
      @last_move = "#{on_move_is} moved: #{these}"
    rescue => error
      @on_turn.reverse!
      raise error
    ensure
      @on_turn.reverse!
    end
  end
end
