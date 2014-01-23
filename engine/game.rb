class RubiesGame
  attr_reader :board, :first_player, :second_player

  def initialize(board, first_player, second_player, db=nil)
    @db            = db
    @board         = board
    @first_player  = first_player
    @second_player = second_player
    @on_turn       = [@first_player, @second_player]
  end

  def on_move_is
    return @on_turn.first
  end

  def make_move(these)
    begin
      @board.take_out(*these)
    rescue MustTakeFromOneRow, RubiesNotConnected, OutOfBoard, RubyAlreadyTaken
      @on_turn.reverse!
      raise
    ensure
      @on_turn.reverse!
    end
  end

  def winner
    if @board.empty?
      update_players_stats
      @on_turn.first
    end
  end

  def update_players_stats
    if @db
    end
  end

  def human_move(move)
    rubies_to_take = parser(move)
    make_move(rubies_to_take)
  end

  def print_board
    puts "-" * (@board.board.keys.map { |_, x| x }.max * 2 - 1) + "\n"
    puts @board.picture
    puts "-" * (@board.board.keys.map { |_, x| x }.max * 2 - 1) + "\n"
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
