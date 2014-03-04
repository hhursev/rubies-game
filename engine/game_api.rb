module RubiesGameAPI
  def move_parser(move)
    rubies_to_take = []
    move.split(',').map do |str|
      row, column = str.split(' ')
      rubies_to_take << [row.to_i, column.to_i]
    end
    rubies_to_take
  end

  def array_representation_of(board)
    board.board.keys.sort.group_by(&:first).values().map do |row|
      row.map { |row, col| board.filled_at?(row, col) ? 1 : 0 }
    end
  end

  def board_string(board)
    board_in_array = array_representation_of board
    width = 2 * board_in_array.max_by(&:size).size
    board_in_array.map do |row|
      row.map { |elem| draw_elem elem }.join(' ').center(width).rstrip + "\n"
    end.join('').chop
  end

  def save(game)
    file_name = Time.now.strftime("%d_%m_%y_at_%H-%M-%S")
    file = File.open("saved_games/#{file_name}", "w")
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
