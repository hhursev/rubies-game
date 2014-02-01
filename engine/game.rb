class RubiesGame
  attr_reader :board, :first_player, :second_player, :ai_difficulty

  def initialize(board, first_player, second_player, ai_difficulty)
    @board         = board
    @first_player  = first_player
    @second_player = second_player
    @ai_difficulty = ai_difficulty
    @last_move     = ""
    @on_turn       = [@first_player, @second_player]
  end

  def winner
    if @board.empty?
      @on_turn.first
    end
  end

  def on_move_is
    return @on_turn.first
  end

  def show_last_move
    puts @last_move
  end

  def make_move(these)
    begin
      @board.take_out(*these)
      @last_move = "#{on_move_is} moved: #{these}"
    rescue MustTakeFromOneRow, RubiesNotConnected, OutOfBoard, RubyAlreadyTaken, SelectSomething
      @on_turn.reverse!
      raise
    ensure
      @on_turn.reverse!
    end
  end

  def human_move(move)
    rubies_to_take = parser(move)
    make_move(rubies_to_take)
  end

  def print_board
    "-" * (@board.board.keys.map { |_, x| x }.max * 2 - 1) + "\n" +
    @board.picture                                         + "\n" +
    "-" * (@board.board.keys.map { |_, x| x }.max * 2 - 1) + "\n"
  end

  def self.dump_to_file(game, file_name)
    file_name = Time.now.strftime("%d_%m_%y_at_%H-%M-%S") if file_name.empty?
    file = File.open("saved_games/#{file_name}", "w")
    Marshal.dump(game, file)
    file.close
  end

  private

  def parser(move)
    rubies_to_take = []
    move.split(',').map do |str|
      row, column = str.split(' ')
      rubies_to_take << [row.to_i, column.to_i]
    end
    rubies_to_take
  end
end
