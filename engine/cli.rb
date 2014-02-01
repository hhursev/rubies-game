# $:.unshift File.dirname(__FILE__)
require_relative "board"
require_relative "game"
require_relative "ai"

class CLIGameplay
  def initialize
    @computer, @play_vs_ai, @ai_difficulty, @start_second_vs_ai, @load = nil
    play_new_game_or_load?
    if @load == "load"
      load_game
    else
      initialize_game
    end
    play_game
  end

  private

  def play_new_game_or_load?
    until @load == "load" or @load == "new"
      puts "do you want to load from saved game or start new one load/new"
      @load = gets.chomp
    end
  end

  def play_vs_ai?
    until @play_vs_ai == "y" or @play_vs_ai == "n"
      puts "do you want to play vs AI? y/n"
      @play_vs_ai = gets.chomp
    end
  end

  def ai_difficulty?
    if @play_vs_ai == "y"
      until @ai_difficulty == "hard" or @ai_difficulty == "easy"
        puts "select ai difficulty: hard/easy"
        @ai_difficulty = gets.chomp
      end
    end
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
    start_second_vs_ai?
    if @start_second_vs_ai == "y"
      @game = RubiesGame.new(RubiesBoard.new(), "computer", "human_player", @ai_difficulty)
    else
      @game = RubiesGame.new(RubiesBoard.new(), "human_player", "computer", @ai_difficulty)
    end
  end

  def initialize_game_vs_human
    @game = RubiesGame.new(RubiesBoard.new(), "first_player", "second_player")
  end

  def start_second_vs_ai?
    until @start_second_vs_ai == "y" or @start_second_vs_ai == "n"
      puts "do you want to start second y/n"
      @start_second_vs_ai = gets.chomp
    end
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

  def save_game(player_move)
    player_move.slice!("save")
    RubiesGame.dump_to_file(@game, player_move.strip.tr("/\?:*<>: ","_"))
  end

  def load_game
    saved_games = Dir.entries("saved_games").select { |entry| entry != '.' and entry != '..' }
                                            .join("\n")

    puts "---- LIST OF SAVED GAMES ----\n #{saved_games} \n-------               -------\n"

    until @game != nil
      load_game = gets.chomp
      @game = Marshal.load(File.read("saved_games/#{load_game}"))
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
