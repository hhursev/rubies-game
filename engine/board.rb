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


class RubiesBoard
  attr_reader :board

  def initialize rows=5
    @rows  = rows
    @board = {}
    initialize_board
  end

  def picture
    #must find out the longest column
    #based on it to arrange the rest
    #and centralize them beautifully

    #find out how to test this as
    #we have random board always...
  end

  def take_out(*positions)
    columns = positions.flat_map { |_, column| column }
    raise OutOfBoard         if positions.map { |row, column| filled?(row, column) }.include? nil
    raise MustTakeFromOneRow if positions.map { |row, _| row }.uniq.size > 1
    if columns.size > 1
      raise RubiesNotConnected if columns.map { |x| (columns & [x + 1, x - 1]).any? }.include? false
    end
    positions.map { |row, column| empty(row, column) }
  end

  def empty?
    @board.values.none?
  end

  def filled?(x, y)
    @board[[x, y]]
  end

  private

  def empty(row, column)
    @board[[row, column]] = false
  end

  def fill(row, column)
    @board[[row, column]] = true
  end

  def initialize_board
    1.upto(@rows).map { |row| fill_column row, rand(row..row*2) }
  end

  def fill_column(row, columns_count)
    1.upto(columns_count).each { |column| fill row, column }
  end
end
