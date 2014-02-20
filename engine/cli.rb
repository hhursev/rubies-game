# $:.unshift File.dirname(__FILE__)
require "./board"
require "./game"
require "./ai"

class CLIGameplay
  def initialize
    @computer, @ai_difficulty, @start_second_vs_ai, @load = nil
    initialize_game
    play_game
  end

  private

  def play_vs_ai?
    @play_vs_ai = "y"
  end

  def ai_difficulty?
    @ai_difficulty = "easy"
  end

  def initialize_game
    play_vs_ai?
    ai_difficulty?
    if @play_vs_ai == "y"
      initialize_game_vs_ai
    else
      initialize_game_vs_human
    end
  end

  def initialize_game_vs_ai
    @game = RubiesGame.new(RubiesBoard.new(), "computer", "human_player", @ai_difficulty)
  end

  def initialize_game_vs_human
    @game = RubiesGame.new(RubiesBoard.new(), "first_player", "second_player")
  end

  def play_game
    while true
      return puts "The winner is " + @game.winner if @game.winner
      puts @game.print_board
      make_move
    end
  end

  def make_move
    puts @game.last_move
    if @game.on_move_is == "computer"
      computer_move
    else
      player_move
    end
  end

  def computer_move
    computer = AI.new(@game.board, @game.ai_difficulty.to_sym)
    ai_move = computer.moves
    @game.make_move ai_move
  end

  def player_move
    puts "write down your move " + @game.on_move_is + "\n"
    player_move = gets.chomp
    save_game(player_move) if player_move.start_with? "save"
    begin
      @game.human_move(player_move)
    rescue Exception => e
      puts e.message
    end
  end
end

while true
  play = nil
  until play == "y" or play == "n"
    puts "do you want to play a game? y/n"
    play = gets.chomp
  end
  if play == "n"
    puts "Fuck you and have a nice day :)"
    exit
  else
    CLIGameplay.new()
  end
end
