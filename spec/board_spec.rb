require '../engine/board'

describe "RubiesBoard" do
  let (:board) { make_board }
  let (:small_board) { make_board 2 }

  it "verifies that board attribute is not editable" do
    board.should_not respond_to :board=
  end

  it "verifies that board attribute is readable" do
    board.should respond_to :board
  end

  it "freshly setted board always has [1, 1]" do
    board.filled?(1, 1).should eq true
    small_board.filled?(1, 1).should eq true
  end

  it "initialize rows and columns within the correct range" do
    (board.board.keys().map { |r, c| r <= 5 and c <= 10 }.all?).should eq true
    (small_board.board.keys().map { |r, c| r <= 2 and c <= 4}.all?).should eq true
  end

  it "makes correct count of columns for every row" do
    (board.board.keys().map { |r, c| c.between?(1, r*2) }.all?).should eq true
    (small_board.board.keys().map { |r, c| c.between?(1, r*2) }.all?).should eq true
  end

  it "empties the board on given position" do
    board.board[[1, 1]].should eq true
    board.take_out([1, 1])
    board.board[[1, 1]].should eq false
  end

  it "indicates if board is empty" do
    board.empty?.should eq false
    board.take_out([1, 1])
    board.empty?.should eq false
    board_positions = board.board.keys()
    board_positions.map { |position| board.take_out position }
    board.empty?.should eq true
  end

  it "moves multiple rubies off the board" do
  end

  it "raises error when move is against the rules" do
  end

  it "raises custom error when out of board action occurs" do
  end

  it "raises error when rubies taken are not on same row" do
  end

  it "raises error when rubies taken are not connected" do
  end
end

def make_board(*args)
  RubiesBoard.new(*args)
end
