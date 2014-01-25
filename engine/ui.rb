require 'gosu'
require_relative 'board'
require_relative 'game'
require_relative 'ai'

class UIGamePlay < Gosu::Window

  def initialize
    super(900, 600, false)
    self.caption = "Rubies Game"
    @error = 'press enter to submit your move'
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    rubies_pictures
    initialize_game
    @state = :game
    @rubies_positions = {}
    get_rubies_positions
  end

  def update
    if @state == :game
      make_moves
    end
  end

  def draw
    if @state == :game
      draw_board
    end
  end


  private
  def take_rubies
  end

  def make_moves
    if @game.winner
      @error = "The winner is: " + @game.winner
    elsif @game.on_move_is == 'computer'
      computer = AI.new(@game.board, :hard)
      ai_move = computer.moves
      submit_move(ai_move)
      @error = "The AI moved: " + ai_move.to_s
    end
  end

  def draw_board
    @font.draw(@error, 280, 30, 0, 1.0, 1.0, 0xffffff00)
    @rubies_positions.keys.map do |key|
      if @rubies_positions[key][:status] == :ruby
        @ruby.draw(key.first, key.last, 0)
      elsif @rubies_positions[key][:status] == :selected_ruby
        @selected_ruby.draw(key.first, key.last, 0)
      end
    end
  end

  def get_rubies_positions
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

  def rubies_pictures
    @rubies        = Gosu::Image.load_tiles(self, "../assets/matchsticks.png", 20, 100, false)
    @ruby          = @rubies[0]
    @selected_ruby = @rubies[1]
  end

  def initialize_game
    @game = RubiesGame.new(RubiesBoard.new(), 'computer', 'human_player')
  end

  def button_down(id)
    case @state
    when :game
      game_state_button_handler(id)
    when :after_game
      after_game_state_button_handler(id)
    when :intro
      intro_state_button_handler(id)
    when :difficulty
      difficulty_state_button_handler(id)
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
    end

    if id == Gosu::KbReturn and @game.on_move_is != 'computer'
      player_move = []
      @rubies_positions.values.map do |value|
        player_move << value[:board_position] if value[:status] == :selected_ruby
      end
      submit_move(player_move)
    end
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

window = UIGamePlay.new
window.show