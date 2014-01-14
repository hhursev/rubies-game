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

    BOARD_1_2_3_5_8 = {
      [1, 1] => nil, [2, 1] => nil, [2, 2] => nil, [3, 1] => nil,
      [3, 2] => nil, [3, 3] => nil, [4, 1] => nil, [4, 2] => nil,
      [4, 3] => nil, [4, 4] => nil, [4, 5] => nil, [5, 1] => nil,
      [5, 2] => nil, [5, 3] => nil, [5, 4] => nil, [5, 5] => nil,
      [5, 6] => nil, [5, 7] => nil, [5, 8] => nil
                      }

    it "checks that algorithms responds to stacks" do
      master_algorithm.should respond_to :stacks
      junior_algorithm.should respond_to :stacks
    end

    it "checks that algorithms respond to nim_sum_zero?" do
      master_algorithm.should respond_to :nim_sum_zero?
      junior_algorithm.should respond_to :nim_sum_zero?
    end

    it "checks that algorithms respond to decision" do
      master_algorithm.should respond_to :decision
      junior_algorithm.should respond_to :decision
    end

    it "tests if i can create custom board" do
      board_hash = { [1, 1] => nil, [2, 1] => nil, [2, 2] => nil }
      custom_board = make_board custom_board: board_hash
      custom_board.board.keys().should eq board_hash.keys()
    end

    it "tests if AI calculates stacks correctly on untouched board" do
      <<-UNTOUCHED_BOARD_1_2_3_5_8_vol1
            x
           x x
          x x x
         x x x x x
      x x x x x x x x
      UNTOUCHED_BOARD_1_2_3_5_8_vol1

      board_hash   = BOARD_1_2_3_5_8
      custom_board = make_board custom_board: board_hash
      test_ai      = master_algorithm custom_board
      test_ai.stacks.should eq [1, 2, 3, 5, 8]
    end

    it "tests if AI calculates stacks correctly on dented board" do
      <<-DENTED_BOARD_1_2_3_5_8_vol1
            x
           o x
          x o o
         x x x x x
      x x x o x x x x
      DENTED_BOARD_1_2_3_5_8_vol1

      board_hash   = BOARD_1_2_3_5_8
      custom_board = make_board custom_board: board_hash
      custom_board.take_out [2, 1]
      custom_board.take_out [3, 2], [3, 3]
      custom_board.take_out [5, 4]
      test_ai = master_algorithm custom_board
      test_ai.stacks.should eq [1, 1, 1, 5, 3, 4]
    end

    it "tests if AI nim sum zero works correctly on given denter boards 1" do
      <<-DENTED_BOARD_1_2_3_5_8_vol2
            x
           o x
          x o o
         x x x x x
      x x x o x x x x
      DENTED_BOARD_1_2_3_5_8_vol2

      board_hash   = BOARD_1_2_3_5_8
      custom_board = make_board custom_board: board_hash
      custom_board.take_out [2, 1]
      custom_board.take_out [3, 2], [3, 3]
      custom_board.take_out [5, 4]
      test_ai = master_algorithm custom_board
      test_ai.nim_sum_zero?.should eq false
    end

    it "tests if AI nim sum zero works correctly on given dented boards 1" do
      <<-DENTED_BOARD_1_2_3_5_8_vol2
            x
           o x
          x o o
         x x x x x
      x o x o x x x x
      DENTED_BOARD_1_2_3_5_8_vol2

      board_hash   = BOARD_1_2_3_5_8
      custom_board = make_board custom_board: board_hash
      custom_board.take_out [2, 1]
      custom_board.take_out [3, 2], [3, 3]
      custom_board.take_out [5, 2]
      custom_board.take_out [5, 4]
      test_ai = master_algorithm custom_board
      test_ai.nim_sum_zero?.should eq true
    end

    def master_algorithm(*args)
      args.empty? ? AI::MasterAlgorithm.new(board) : AI::MasterAlgorithm.new(*args)
    end

    def junior_algorithm(*args)
      args.empty? ? AI::JuniorAlgorithm.new(board) : AI::JuniorAlgorithm.new(*args)
    end
  end
end

def make_board(*args)
  RubiesBoard.new(*args)
end

def make_ai(*args)
  args.empty? ? AI.new(make_board) : AI.new(*args)
end


