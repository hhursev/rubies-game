require 'gosu'
require_relative 'board'
require_relative 'game'
require_relative 'ai'

class Button < Gosu::TextInput
  def initialize(window, font, text, x, y)
    super()
    @window = window
    @font   = font
    @text   = text
    @x, @y  = x, y
  end

  def draw(background_color)
    @window.draw_quad(@x,         @y,          background_color,
                      @x + width, @y,          background_color,
                      @x,         @y + height, background_color,
                      @x + width, @y + height, background_color, 0)
    @font.draw(@text, @x, @y, 0)
  end

  def width
    250
  end

  def height
    @font.height
  end

  def hovered?(mouse_x, mouse_y)
    mouse_x > @x and mouse_x < @x + width and mouse_y > @y and mouse_y < @y + height
  end

  def clicked_on(mouse_x, mouse_y)
    return @text if hovered? mouse_x, mouse_y
  end
end

class UIGameplay < Gosu::Window
  def initialize
    super(900, 600, false)
    self.caption = "Rubies Game"

    rubies_pictures
    @state = :intro_menu
    @error = ''
    @rubies_positions = {}
  end

  def update
    case @state
    when :intro_menu
      intro_menu
    when :load
      load
    when :game
      game
    end
  end

  def draw
    case @state
    when :intro_menu
      draw_intro_menu
    when :load
      draw_load_menu
    when :game
      draw_game
    end
  end

  private

  def intro_menu
    buttons = ["Play vs friend", "Play vs AI", "Load game", "Exit"]
    font  = Gosu::Font.new(self, Gosu::default_font_name, 40)
    @menu_entries = Array.new(4) { |i| Button.new(self, font, buttons[i], 325, 130 + i * 100) }
  end

  def draw_intro_menu
    standart = 0xcc666666
    hovered  = 0xccff6666
    @menu_entries.each { |me| me.hovered?(mouse_x, mouse_y) ? me.draw(hovered) : me.draw(standart) }
  end

  def load
    games = Dir.entries("saved_games").select { |entry| entry != '.' and entry != '..' }
    font = Gosu::Font.new(self, Gosu::default_font_name, 25)
    @load_games = Array.new(games.size) { |i| Button.new(self, font, games[i], 325, 130 + i * 30) }
  end

  def draw_load_menu
    standart = 0xcc666666
    hovered  = 0xccff6666
    @load_games.each { |sg| sg.hovered?(mouse_x, mouse_y) ? sg.draw(hovered) : sg.draw(standart) }
  end

  def game
    game_buttons
    make_moves
  end

  def draw_game
    initialize_rubies_positions if @rubies_positions == {}
    draw_board
    draw_game_buttons
  end

  def game_buttons
    buttons = ["Submit", "New game", "Save game", "Quit"]
    font = Gosu::Font.new(self, Gosu::default_font_name, 40)
    @game_buttons = Array.new(4) { |i| Button.new(self, font, buttons[i], 600, 380 + i * 50) }
  end

  def draw_game_buttons
    standart = 0xcc666666
    hovered  = 0xccff6666
    @game_buttons.each { |gb| gb.hovered?(mouse_x, mouse_y) ? gb.draw(hovered) : gb.draw(standart) }
  end

  def initialize_rubies_positions
    x_offset = 50
    y_offset = -90
    row_pos  = 1
    column   = 0
    @game.print_board.split("\n").map do |row|
      row.each_char do |symbol|
        if symbol == '-' or symbol == ' '
          x_offset += 20
        elsif symbol == 'o'
          x_offset += 20
          row_pos  += 1
        else
          @rubies_positions.update([x_offset, y_offset] =>
                                   {:board_position => [column, row_pos], :status => :ruby})
          x_offset += 20
          row_pos  += 1
        end
      end
      x_offset  = 50
      y_offset += 110
      row_pos   = 1
      column   += 1
    end
  end

  def make_moves
    if @game.winner
      @error = "The winner is: " + @game.winner
      @rubies_positions = {}
    elsif @game.on_move_is == 'computer'
      computer = AI.new(@game.board, @game.ai_difficulty.to_sym)
      ai_move = computer.moves
      submit_move(ai_move)
    end
  end

  def draw_board
    font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    font.draw("#{@game.last_move}"           , 280, 10, 0, 1.0, 1.0, 0xffffff00)
    font.draw(@error                         , 280, 30, 0, 1.0, 1.0, 0xffff0000)
    font.draw("It's #{@game.on_move_is} turn", 280, 50, 0, 1.0, 1.0, 0xff00ff00)
    @rubies_positions.keys.map do |key|
      if @rubies_positions[key][:status] == :ruby
        @ruby.draw(key.first, key.last, 0)
      elsif @rubies_positions[key][:status] == :selected_ruby
        @selected_ruby.draw(key.first, key.last, 0)
      end
    end
  end

  def rubies_pictures
    rubies         = Gosu::Image.load_tiles(self, "../assets/matchsticks.png", 20, 100, false)
    @ruby          = rubies.first
    @selected_ruby = rubies.last
  end

  def initialize_game_vs_human
    @game  = RubiesGame.new(RubiesBoard.new(), 'human_player_1', 'human_player_2')
    @state = :game
  end

  def initialize_game_vs_ai
    @game  = RubiesGame.new(RubiesBoard.new(), 'computer', 'human_player', 'hard')
    @state = :game
  end

  def button_down(id)
    case @state
    when :intro_menu
      intro_menu_state_button_handler(id)
    when :load
      load_state_button_handler(id)
    when :game
      game_state_button_handler(id)
    end
  end

  def intro_menu_state_button_handler(id)
    if id == Gosu::MsLeft
      clicked_button = @menu_entries.map { |me| me.clicked_on(mouse_x, mouse_y) }
      case clicked_button.compact.first
      when "Play vs friend"
        initialize_game_vs_human
      when "Play vs AI"
        initialize_game_vs_ai
      when "Load game"
        @state = :load
      when "Exit"
        exit
      end
    end
  end

  def load_state_button_handler(id)
    if id == Gosu::MsLeft
      clicked_game = @load_games.map { |game| game.clicked_on(mouse_x, mouse_y) }
      @game  = Marshal.load(File.read("saved_games/#{clicked_game.compact.first}"))
      @state = :game
    end
  end

  def game_state_button_handler(id)
    if id == Gosu::MsLeft
      if within_ruby_reach?
        case @rubies_positions[within_ruby_reach?][:status]
        when :selected_ruby
          @rubies_positions[within_ruby_reach?].update(:status => :ruby)
        when :ruby
          @rubies_positions[within_ruby_reach?].update(:status => :selected_ruby)
        end
      end

      clicked_buttons = @game_buttons.map { |btn| btn.clicked_on(mouse_x, mouse_y) }
      case clicked_buttons.compact.first
      when "Submit"
        player_move = []
        @rubies_positions.values.map do |value|
          player_move << value[:board_position] if value[:status] == :selected_ruby
        end
        submit_move(player_move)
      when "New game"
        new_game
      when "Save game"
        RubiesGame.dump_to_file(@game, '')
      when "Quit"
        @rubies_positions = {}
        @state = :intro_menu
      end
    end

    if id == Gosu::KbReturn and @game.on_move_is != 'computer'
      player_move = []
      @rubies_positions.values.map do |value|
        player_move << value[:board_position] if value[:status] == :selected_ruby
      end
      submit_move(player_move)
    end
  end

  def new_game
    first_player  = @game.first_player
    second_player = @game.second_player
    @error = ''
    @rubies_positions = {}
    @game  = RubiesGame.new(RubiesBoard.new(), second_player, first_player, 'hard')
    @state = :game
  end

  def submit_move(move)
    begin
      @game.make_move(move)
      @rubies_positions.values.map do |value|
        value[:status] = :taken_ruby if move.include?(value[:board_position])
      end
      @error = ''
    rescue Exception => e
      @error = e.message
    ensure
      @on_move_is = "It's "+ @game.on_move_is + "'s turn"
    end
  end

  def within_ruby_reach?
    @rubies_positions.keys.map do |ruby_position|
      if (ruby_position[0] + 20 >= mouse_x and ruby_position[1] + 100 >= mouse_y and
          ruby_position[0] <= mouse_x and ruby_position[1] <= mouse_y)
        return ruby_position
      end
    end
    return false
  end

  def needs_cursor?
    true
  end
end

window = UIGameplay.new
window.show