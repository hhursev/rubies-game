require 'gosu'
require_relative 'ai'
require_relative 'game'
require_relative 'board'
require_relative 'game_api'

NORMAL          = 0xcc666666
HOVERED         = 0xccff6666
RUBY_WIDTH      = 20
RUBY_HEIGHT     = 100
WINDOW_WIDTH    = 900
WINDOW_HEIGHT   = 600
SAVED_GAMES_DIR = 'saved_games'

class UIGameplay < Gosu::Window
  include RubiesGameAPI

  def initialize
    super(WINDOW_WIDTH, WINDOW_HEIGHT, false)
    self.caption = "Rubies Game"

    get_rubies_pictures
    @state  = :intro_menu
    @error  = ''
    @rubies = {}
  end

  def update
    case @state
    when :intro_menu
      intro_menu
    when :load
      load
    when :game
      game
      make_moves
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
    buttons = ["Play vs friend", "Play vs AI", "Load Game", "Exit"]
    @buttons = Array.new(4) { |i| Button.new(self, buttons[i], y_offset: 130 + i * 45 )}
  end

  def draw_buttons
    @buttons.each { |btn| btn.hovered?(mouse_x, mouse_y) ? btn.draw(HOVERED) : btn.draw(NORMAL) }
  end

  def draw_intro_menu
    draw_buttons
  end

  def load
    games = saved_games_in SAVED_GAMES_DIR
    games.push("Go back")
    @buttons = Array.new(games.size) { |i| Button.new(self, games[i], y_offset: 130 + i * 45 ) }
  end

  def draw_load_menu
    draw_buttons
  end

  def game
    btns = ["Submit", "New game", "Save game", "Go back"]
    @buttons = Array.new(4) { |i| Button.new(self, btns[i], x_offset: 600, y_offset: 380 + i * 45) }
    get_rubies_positions if @rubies == {}
  end

  def draw_game
    draw_buttons
    draw_rubies
    draw_info_texts
  end

  def draw_info_texts
    font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    font.draw("#{@game.last_move}"           , 280, 10, 0, 1.0, 1.0, 0xffffff00)
    font.draw(@error                         , 280, 30, 0, 1.0, 1.0, 0xffff0000)
    font.draw("It's #{@game.on_move_is} turn", 280, 50, 0, 1.0, 1.0, 0xff00ff00)
  end

  def draw_rubies
    untouched_rubies_positions.map { |pos| @ruby.draw(pos.first, pos.last, 0) }
    selected_rubies_positions.map { |pos| @selected_ruby.draw(pos.first, pos.last, 0) }
  end

  def untouched_rubies_positions
    @rubies.keys.keep_if { |key| @rubies[key][:status] == :untouched }
  end

  def selected_rubies_positions
    @rubies.keys.keep_if { |key| @rubies[key][:status] == :selected }
  end

  def get_rubies_pictures
    rubies         = Gosu::Image.load_tiles(self, "../assets/matchsticks.png", 20, 100, false)
    @ruby          = rubies.first
    @selected_ruby = rubies.last
  end

  def initialize_game_vs_human
    @game  = RubiesGame.new(RubiesBoard.new(), "player1", "player2")
    @state = :game
  end

  def initialize_game_vs_ai
    @game  = RubiesGame.new(RubiesBoard.new(), "computer", "player", "hard")
    @state = :game
  end

  def button_down(id)
    case @state
    when :intro_menu
      intro_menu_state_button_handler id
    when :load
      load_state_button_handler id
    when :game
      game_state_button_handler id
    end
  end

  def intro_menu_state_button_handler(id)
    if id == Gosu::MsLeft
      case button_clicked
      when "Play vs friend"
        initialize_game_vs_human
      when "Play vs AI"
        initialize_game_vs_ai
      when "Load Game"
        @state = :load
      when "Exit"
        exit
      end
    end
  end

  def load_state_button_handler(id)
    if id == Gosu::MsLeft
      case button_clicked
      when "Go back"
        @state = :intro_menu
      else
        @game = load_game SAVED_GAMES_DIR, button_clicked
        @state = :game
      end
    end
  end

  def make_moves
    if @game.winner
      @error  = "The winner is: " + @game.winner
      @rubies = {}
    elsif @game.on_move_is == "computer"
      computer = AI.new(@game.board, @game.ai_difficulty.to_sym)
      ai_move = computer.moves
      @game.make_move ai_move
      get_rubies_positions
    end
  end

  def submit_move
    begin
      selected = selected_rubies_positions.map { |pos| @rubies[pos][:position] }
      @game.make_move(selected)
      @error = ''
      get_rubies_positions
    rescue Exception => e
      @error = e.message
    end
  end

  def game_state_button_handler(id)
    if id == Gosu::MsLeft
      game_state_mouse_handler(id)
    elsif id == Gosu::KbReturn and @game.on_move_is != 'computer'
      submit_move
    end
  end

  def game_state_mouse_handler(id)
    if within_ruby_reach?
      case @rubies[within_ruby_reach?][:status]
      when :selected
        @rubies[within_ruby_reach?].update(:status => :untouched)
      when :untouched
        @rubies[within_ruby_reach?].update(:status => :selected)
      end
    end

    case button_clicked
      when "Submit"
        submit_move
      when "New game"
        new_game
      when "Save game"
        save @game
      when "Go back"
        @rubies = {}
        @state  = :intro_menu
    end
  end

  def new_game
    @rubies = {}
    @error  = ''
    first_player, second_player = @game.first_player, @game.second_player
    @game = RubiesGame.new(RubiesBoard.new(), second_player, first_player)
  end

  def button_clicked
    @buttons.map { |btn| btn.clicked_on(mouse_x, mouse_y) }.compact.first
  end

  def needs_cursor?
    true
  end

  def within_ruby_reach?
    @rubies.keys.map do |ruby_position|
      if (ruby_position[0] + 20 >= mouse_x and ruby_position[1] + 100 >= mouse_y and
          ruby_position[0] <= mouse_x and ruby_position[1] <= mouse_y)
        return ruby_position
      end
    end
    return false
  end

  def get_rubies_positions
    board_str = board_string @game.board
    x = 30
    y = 10
    row = column = 1
    board_str.each_char do |symbol|
      if symbol == " "
        x += RUBY_WIDTH
      elsif symbol == "o" or symbol == "x"
        @rubies.update([x, y] =>
                       {:position => [row, column], :status => :untouched}) if symbol == "x"
        @rubies.update([x, y] =>
                       {:position => [row, column], :status => :taken}) if symbol == "o"
        column += 1
        x += RUBY_WIDTH
      elsif symbol == "\n"
        column = 1
        row += 1
        x = 30
        y += RUBY_HEIGHT + 20
      end
    end
    @rubies
  end
end

class Button < Gosu::TextInput
  def initialize(window, text, x_offset: nil, y_offset: nil)
    super()
    @window = window
    @text   = text
    @font   = Gosu::Font.new(@window, Gosu::default_font_name, 30)
    x_offset ? @x = x_offset : center_button_horizontally
    y_offset ? @y = y_offset : center_button_vertically
  end

  def draw(background_color)
    @window.draw_quad(@x,         @y,          background_color,
                      @x + width, @y,          background_color,
                      @x,         @y + height, background_color,
                      @x + width, @y + height, background_color, 0)
    @font.draw(@text, @x, @y, 0)
  end

  def hovered?(mouse_x, mouse_y)
    mouse_x > @x and mouse_x < @x + width and mouse_y > @y and mouse_y < @y + height
  end

  def clicked_on(mouse_x, mouse_y)
    @text if hovered? mouse_x, mouse_y
  end

  private

  def width
    200
  end

  def height
    @font.height
  end

  def center_button_horizontally
    @x = (WINDOW_WIDTH - width) / 2
  end

  def center_button_vertically
    @y = WINDOW_HEIGHT / 2
  end
end

window = UIGameplay.new
window.show
