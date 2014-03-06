module RubiesGameAPI
  def move_parser(move)
    rubies_to_take = []
    move.split(',').map do |str|
      row, column = str.split(' ')
      rubies_to_take << [row.to_i, column.to_i]
    end
    rubies_to_take
  end

  def array_representation_of(ruby_board)
    ruby_board.board.keys.sort.group_by(&:first).values().map do |row|
      row.map { |row, col| ruby_board.filled_at?(row, col) ? 1 : 0 }
    end
  end

  def board_string(board)
    board_in_array = array_representation_of board
    width = 2 * board_in_array.max_by(&:size).size
    board_in_array.map do |row|
      row.map { |elem| draw_elem elem }.join(' ').center(width).rstrip + "\n"
    end.join('').chop
  end

  def save(game, f_name=false, in_dir=false)
    f_name ? file_name = f_name : file_name = Time.now.strftime("%d_%m_%y_at_%H-%M-%S")
    in_dir ? directory = in_dir : directory = "saved_games"
    file = File.open("#{directory}/#{file_name}", "w")
    Marshal.dump(game, file)
    file.close
  end

  def load_game(from_dir, file_name)
    Marshal.load(File.read("#{from_dir}/#{file_name}"))
  end

  def saved_games_in(directory)
    Dir.entries(directory).select { |entry| entry != '.' and entry != '..' }
  end

  private

  def draw_elem(elem)
    elem == 1 ? 'x' : 'o'
  end
end

class RubiesPositionsToDraw
  include RubiesGameAPI

  attr_reader :rubies

  def initialize(board)
    @row, @column        = 1, 1
    @x_offset, @y_offset = 30, 10
    @rubies              = {}
    @board_str           = board_string board
    draw_rubies
  end

  def add_horizontal_margin
    @x_offset += RUBY_WIDTH
  end

  def draw_ruby_there
    @rubies.update([@x_offset, @y_offset] =>
                   {:position => [@row, @column], :status => :untouched})
    @column += 1
    add_horizontal_margin
  end

  def draw_taken_ruby
    @rubies.update([@x_offset, @y_offset] =>
                   {:position => [@row, @column], :status => :taken})
    @column += 1
    add_horizontal_margin
  end

  def go_to_next_line
    @row      += 1
    @column    = 1
    @x_offset  = 30
    @y_offset += (RUBY_HEIGHT + 20)
  end

  def draw_rubies
    @board_str.each_char do |symbol|
      add_horizontal_margin if symbol == " "
      draw_ruby_there if symbol == "x"
      draw_taken_ruby if symbol == "o"
      go_to_next_line if symbol == "\n"
    end
  end
end
