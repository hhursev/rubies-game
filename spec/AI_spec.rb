require "spec_helper"

class RubiesBoard
  def initialize(rows=5, custom_board: false)
    @rows = rows
    custom_board ? @board = custom_board : @board = {}
    initialize_board custom_board
  end

  private

  def initialize_board(custom_board)
    if custom_board
      board.keys.map { |row, column| fill row, column }
    else
      1.upto(@rows).map { |row| fill_column row, rand(row..row*2) }
    end
  end
end

describe "AI" do
  describe "MasterAlgorithm" do
    let (:ai)               { make_ai }
    let (:board)            { make_board }
    let (:master_algorithm) { master_algorithm }
    let (:junior_algorithm) { junior_algorithm }

    it "check that algorithms respond to decision" do
      master_algorithm.should respond_to :decision
      junior_algorithm.should respond_to :decision
    end

    it "tests if i can create custom board" do
      board_hash = { [1, 1] => nil, [2, 1] => nil, [2, 2] => nil }
      custom_board = make_board(custom_board: board_hash)
      custom_board.board.keys().should eq board_hash.keys()
    end

    def master_algorithm(*args)
      args.empty? ? AI::MasterAlgorithm.new(board) : AI::MasterAlgorithm(*args)
    end

    def junior_algorithm(*args)
      args.empty? ? AI::JuniorAlgorithm.new(board) : AI::JuniorAlgorithm(*args)
    end
  end
end

def make_board(*args)
  RubiesBoard.new(*args)
end

def make_ai(*args)
  args.empty? ? AI.new(make_board) : AI.new(*args)
end


