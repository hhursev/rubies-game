class BoardErrorsHandler
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

  class << self
    def check_for_errors(positions, board)
      @@positions, @@board = positions, board
      raise SelectSomething    unless someting_is_selected
      raise OutOfBoard         unless in_boards_reach
      raise RubyAlreadyTaken   unless rubies_not_taken
      raise MustTakeFromOneRow unless rubies_from_one_row
      raise RubiesNotConnected unless rubies_connected
    end

    def someting_is_selected
      @@positions.size > 0
    end

    def in_boards_reach
      @@positions.none? { |row, column| @@board.filled_at?(row, column) == nil }
    end

    def rubies_not_taken
      @@positions.all? { |row, column| @@board.filled_at?(row, column) == true }
    end

    def rubies_from_one_row
      @@positions.map { |row, _| row }.uniq.size == 1
    end

    def rubies_connected
      columns = @@positions.flat_map { |_, column| column }
      return true if columns.size == 1
      columns.all? { |x| (columns & [x + 1, x - 1]).any? }
    end
  end
end

class RubiesBoard
  attr_reader :board

  def initialize(rows=5, custom_board: false)
    @rows  = rows
    @board = {}
    if custom_board
      custom_board.keys.map { |row, column| @board[[row, column]] = true }
    else
      populate_random_board
    end
  end

  def take_out(*positions)
    begin
      BoardErrorsHandler.check_for_errors(positions, self)
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

  def populate_random_board
    1.upto(@rows).each do |row|
      1.upto(rand(row..row*2)).map { |column| @board[[row, column]] = true }
    end
  end

  def empty(row, column)
    @board[[row, column]] = false
  end
end
