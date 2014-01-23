# $:.unshift File.dirname(__FILE__)
require_relative 'board'
require_relative 'player'
require_relative 'game'
require_relative 'ai'

class CLIGamePlay
  def initialize
    @computer, @play_vs_ai, @ai_difficulty, @start_second_vs_ai = nil
    initialize_game
    play_game
  end

  private

  def play_vs_ai?
    until @play_vs_ai == 'y' or @play_vs_ai == 'n'
      puts "do you want to play vs AI? y/n"
      @play_vs_ai = gets.chomp
    end
  end

  def ai_difficulty?
    if @play_vs_ai == 'y'
      until @ai_difficulty == 'hard' or @ai_difficulty == 'easy'
        puts "select ai difficulty: hard/easy"
        @ai_difficulty = gets.chomp
      end
    end
  end

  def initialize_game
    play_vs_ai?
    ai_difficulty?
    if @play_vs_ai == 'y'
      initialize_game_vs_ai
    else
      initialize_game_vs_human
    end
  end

  def initialize_game_vs_ai
    start_second_vs_ai?
    if @start_second_vs_ai == 'y'
      @game = RubiesGame.new(RubiesBoard.new(), 'computer', 'human_player')
    else
      @game = RubiesGame.new(RubiesBoard.new(), 'human_player', 'computer')
    end
  end

  def initialize_game_vs_human
    @game = RubiesGame.new(RubiesBoard.new(), 'first_player', 'second_player')
  end

  def start_second_vs_ai?
    until @start_second_vs_ai == 'y' or @start_second_vs_ai == 'n'
      puts "do you want to start second y/n"
      @start_second_vs_ai = gets.chomp
    end
  end

  def play_game
    while true
      return puts "The winner is " + @game.winner if @game.winner
      @game.print_board
      make_move
    end
  end

  def make_move
    if @game.on_move_is == 'computer'
      computer_move
    else
      player_move
    end
  end

  def computer_move
    computer = AI.new(@game.board, @ai_difficulty.to_sym)
    ai_move = computer.moves
    @game.make_move ai_move
    puts "The AI moved: " + ai_move.to_s
  end

  def player_move
    puts "write down your move " + @game.on_move_is + "\n"
    player_move = gets.chomp
    begin
      @game.human_move(player_move)
    rescue Exception => e
      puts e.message
    end
  end
end

while true
  play = nil
  until play == 'y' or play == 'n'
    puts "do you want to play a game? y/n"
    play = gets.chomp
  end
  if play == 'n'
    puts "Fuck you and have a nice day :)"
    exit
  else
    CLIGamePlay.new()
  end
end
