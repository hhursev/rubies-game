class RubiesBoard
  attr_reader :board

  def initialize rows=5
    @rows  = rows
    @board = {}
    initialize_board
  end

  def picture
  end

  def take_out(*positions)
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
