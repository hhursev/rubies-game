require "spec_helper"

class RubiesBoard
  def initialize(rows=5, custom_board: false)
    @rows  = rows
    @board = {}
    if custom_board
      custom_board.keys.map { |row, column| @board[[row, column]] = true }
    else
      1.upto(rows).each do |row|
        1.upto(rand(row..row*2)).map { |column| @board[[row, column]] = true }
      end
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

    it "checks that AI responds to moves" do
      ai.should respond_to :moves
    end

    it "checks that AI responds to rubies_board reader" do
      ai.should respond_to :rubies_board
    end

    it "checks that AI responds to difficulty reader" do
      ai.should respond_to :difficulty
    end

    it "says AI doesnt respond to rubies_board setter after initialization" do
      ai.should_not respond_to :rubies_board=
    end

    it "says AI doesnt respond to difficulty setter after initialization" do
      ai.should_not respond_to :difficulty=
    end

    it "checks that algorithms responds to stacks" do
      master_algorithm.should respond_to :stacks
      junior_algorithm.should respond_to :stacks
    end

    it "checks that master algorithm responds to nim_sum_zero?" do
      master_algorithm.should respond_to :nim_sum_zero?
    end

    it "checks that algorithms respond to decision" do
      master_algorithm.should respond_to :decision
      junior_algorithm.should respond_to :decision
    end

    it "checks that master_algorithm responds to perfect move method" do
      master_algorithm.should respond_to :perfect_move
    end

    it "checks that master_algorithm responds to how_many_rubies_from_which_stack" do
      master_algorithm.should respond_to :how_many_rubies_from_which_stack
    end

    it "verifies that the AI initialization works the right way" do
      test_ai = AI.new(make_board, difficulty=:hard)
      test_ai.rubies_board.should be_a(RubiesBoard)
      test_ai.difficulty.should eq :hard
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

    it "verifies MasterAlgorithm plays the perfect move and makes nim sum zero" do
      <<-DENTED_BOARD_1_2_3_5_8_vol3
            x
           o x
          x o o
         x x o x x
      x o x o x x x x
      DENTED_BOARD_1_2_3_5_8_vol3

      board_hash   = BOARD_1_2_3_5_8
      custom_board = make_board custom_board: board_hash
      custom_board.take_out [2, 1]
      custom_board.take_out [3, 2], [3, 3]
      custom_board.take_out [4, 3]
      custom_board.take_out [5, 2]
      custom_board.take_out [5, 4]
      test_ai = make_ai custom_board, difficulty=:hard
      test_ai.moves.should eq [[5, 5], [5, 6], [5, 7]]
    end

    it "make sure algorithm catches cases where odd number of single rubies and one big stack on board" do
      <<-DENTED_BOARD_1_2_3_5_8_vol4
            x
           o x
          o o o
         o o o o x
      o o o o x x x x
      DENTED_BOARD_1_2_3_5_8_vol4

      board_hash   = BOARD_1_2_3_5_8
      custom_board = make_board custom_board: board_hash
      custom_board.take_out [2, 1]
      custom_board.take_out [3, 1], [3, 2], [3, 3]
      custom_board.take_out [4, 1], [4, 2], [4, 3], [4, 4]
      custom_board.take_out [5, 1], [5, 2], [5, 3], [5, 4]
      test_ai = make_ai custom_board, difficulty=:hard
      test_ai.moves.should eq [[5, 5], [5, 6], [5, 7], [5, 8]]
    end

    it "make sure algorithm catches cases where even number of single rubies and one big stack on board" do
      <<-DENTED_BOARD_1_2_3_5_8_vol5
            x
           o x
          o o o
         o o o o x
      x o o o x x x x
      DENTED_BOARD_1_2_3_5_8_vol5

      board_hash   = BOARD_1_2_3_5_8
      custom_board = make_board custom_board: board_hash
      custom_board.take_out [2, 1]
      custom_board.take_out [3, 1], [3, 2], [3, 3]
      custom_board.take_out [4, 1], [4, 2], [4, 3], [4, 4]
      custom_board.take_out [5, 2], [5, 3], [5, 4]
      test_ai = make_ai custom_board, difficulty=:hard
      test_ai.moves.should eq [[5, 5], [5, 6], [5, 7]]
    end

    it "takes ruby when even number of single rubies left" do
      <<-DENTED_BOARD_1_2_3_5_8_vol6
            x
           o x
          o o o
         o o o o x
      x o o o o o o o
      DENTED_BOARD_1_2_3_5_8_vol6

      board_hash   = BOARD_1_2_3_5_8
      custom_board = make_board custom_board: board_hash
      custom_board.take_out [2, 1]
      custom_board.take_out [3, 1], [3, 2], [3, 3]
      custom_board.take_out [4, 1], [4, 2], [4, 3], [4, 4]
      custom_board.take_out [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [5, 8]
      test_ai = make_ai custom_board, difficulty=:hard
      position = test_ai.moves

      position.size.should eq 1
      position.is_a?(Array).should eq true
      custom_board.filled_at?(position[0].first, position[0].last).should eq true
    end

    it "takes ruby when odd number of single rubies left" do
      <<-DENTED_BOARD_1_2_3_5_8_vol7
            x
           o x
          o o o
         o o o o o
      x o o o o o o o
      DENTED_BOARD_1_2_3_5_8_vol7

      board_hash   = BOARD_1_2_3_5_8
      custom_board = make_board custom_board: board_hash
      custom_board.take_out [2, 1]
      custom_board.take_out [3, 1], [3, 2], [3, 3]
      custom_board.take_out [4, 1], [4, 2], [4, 3], [4, 4], [4, 5]
      custom_board.take_out [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [5, 8]
      test_ai = make_ai custom_board, difficulty=:hard
      position = test_ai.moves

      position.size.should eq 1
      position.is_a?(Array).should eq true
      custom_board.filled_at?(position[0].first, position[0].last).should eq true
    end

    it "verifies that AI's random take is by the rules" do
      <<-DENTED_BOARD_1_2_3_5_8_vol8
            x
           o x
          x o o
         x x o x x
      x o x o x x x x
      DENTED_BOARD_1_2_3_5_8_vol8

      board_hash   = BOARD_1_2_3_5_8
      row, column = 0, 1
      custom_board = make_board custom_board: board_hash
      custom_board.take_out [2, 1]
      custom_board.take_out [3, 2], [3, 3]
      custom_board.take_out [4, 3]
      custom_board.take_out [5, 2]
      custom_board.take_out [5, 4]
      test_ai   = make_ai custom_board, difficulty=:junior

      positions = test_ai.moves

      rows    = positions.map { |position| position[row] }
      columns = positions.map { |position| position[column] }

      rows.uniq.size.should eq 1
      positions.each do |position|
        if columns.size > 1
          (columns & [position[column] + 1, position[column] - 1]).any?.should eq true
        end
        custom_board.filled_at?(position[row], position[column]).should eq true
      end
    end

    it "junior algorithm don't use random when single rubies and big stack of rubies" do
      <<-DENTED_BOARD_1_2_3_5_8_vol9
            x
           o x
          x o o
         x o o o o
      x o o o x x x x
      DENTED_BOARD_1_2_3_5_8_vol9

      board_hash   = BOARD_1_2_3_5_8
      row, column = 0, 1
      custom_board = make_board custom_board: board_hash
      custom_board.take_out [2, 1]
      custom_board.take_out [3, 2], [3, 3]
      custom_board.take_out [4, 2], [4, 3], [4, 4], [4, 5]
      custom_board.take_out [5, 2], [5, 3], [5, 4]
      test_ai   = make_ai custom_board, difficulty=:junior
      test_ai.moves.should eq [[5, 5], [5, 6], [5, 7], [5, 8]]
    end

    def master_algorithm(*args)
        args.empty? ? AI::MasterAlgorithm.new(board) : AI::MasterAlgorithm.new(*args)
      end

    def junior_algorithm(*args)
      args.empty? ? AI::JuniorAlgorithm.new(board) : AI::JuniorAlgorithm.new(*args)
    end
  end

  def make_board(*args)
    RubiesBoard.new(*args)
  end

  def make_ai(*args)
    args.empty? ? AI.new(make_board) : AI.new(*args)
  end
end
