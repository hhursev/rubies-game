class BoardErrorHandler
  class MustTakeFromOneRow < StandardError
    def initialize(message="Rubies you take must be from one row")
      super(message)
    end
  end

  class RubiesNotConnected < StandardError
    def initialize(message="Rubies are not connected (read the rules)")
      super(message)
    end
  end

  class OutOfBoard < StandardError
    def initialize(message="You make actions out of the board's reach")
      super(message)
    end
  end

  class RubyAlreadyTaken < StandardError
    def initialize(message="This ruby is already taken")
      super(message)
    end
  end

  class SelectSomething < StandardError
    def initialize(message="At least select something")
      super(message)
    end
  end

  def self.check_for_errors(positions, board)
    raise SelectSomething    unless someting_is_selected positions
    raise OutOfBoard         unless in_boards_reach      positions, board
    raise RubyAlreadyTaken   unless rubies_not_taken     positions, board
    raise MustTakeFromOneRow unless rubies_from_one_row  positions
    raise RubiesNotConnected unless rubies_connected     positions
  end

  private

  def self.someting_is_selected(positions)
    positions.size > 0
  end

  def self.in_boards_reach(positions, board)
    positions.none? { |row, column| board.filled_at?(row, column) == nil }
  end

  def self.rubies_not_taken(positions, board)
    positions.all? { |row, column| board.filled_at?(row, column) == true }
  end

  def self.rubies_from_one_row(positions)
    positions.map { |row, _| row }.uniq.size == 1
  end

  def self.rubies_connected(positions)
    columns = positions.flat_map { |_, column| column }
    return true if columns.size == 1
    columns.all? { |x| (columns & [x + 1, x - 1]).any? }
  end
end

class RubiesBoard
  attr_reader :board

  def initialize(rows=5)
    @board = {}
    1.upto(rows).each do |row|
      1.upto(rand(row..row*2)).map { |column| board[[row, column]] = true }
    end
  end

  def picture
    board_width = 2 * @board.keys.map { |_, column| column }.max
    @board.keys.sort.group_by(&:first).values().map do |row|
      row.map { |row, col| draw_position row, col }.join(' ').center(board_width).rstrip + "\n"
    end.join('').chop
  end

  def take_out(*positions)
    begin
      BoardErrorHandler.check_for_errors(positions, self)
      positions.map { |row, column| empty(row, column) }
    rescue => error
      raise error
    end
  end

  def empty?
    @board.values.none?
  end

  def filled_at?(x, y)
    @board[[x, y]]
  end

  private

  def empty(row, column)
    @board[[row, column]] = false
  end

  def fill(row, column)
    @board[[row, column]] = true
  end

  def fill_column(row, columns_count)
    1.upto(columns_count).each { |column| fill row, column }
  end

  def draw_position(row, column)
    @board[[row, column]] ? draw_ruby : draw_taken_ruby
  end

  def draw_ruby
    'x'
  end

  def draw_taken_ruby
    'o'
  end
end
