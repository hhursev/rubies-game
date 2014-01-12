require "spec_helper"

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
    remove_these = [[2, 1], [2, 2]]
    board.filled?(2, 1).should eq true
    board.take_out(*remove_these)
    board.filled?(2, 1).should eq false
    board.filled?(2, 2).should eq false
  end

  it "does not raise error when taking single ruby" do
    remove_these = [[2, 1]]
    board.take_out(*remove_these)
  end

  it "raises custom error when out of board action occurs" do
    remove_these = [[1, 5]]
    expect { board.take_out(*remove_these) }.to raise_error(OutOfBoard)
  end

  it "raises error when rubies taken are not on same row" do
    remove_these = [[1, 1], [2, 1]]
    expect { board.take_out(*remove_these) }.to raise_error(MustTakeFromOneRow)
  end

  it "raises error when rubies taken are not connected" do
    remove_these = [[3, 1], [3, 3]]
    expect { board.take_out(*remove_these) }.to raise_error(RubiesNotConnected)
  end

  it "check if exceptions are prioritize correctly" do
    # OutOfBoard is with higher priority that others custom exceptions
    remove_these = [[1, 1], [1, 5]]
    expect { board.take_out(*remove_these) }.to raise_error(OutOfBoard)
  end

  it "check if MustTakeFromOneRow is with higher priority than RubiesNotConnected" do
    remove_these = [[3, 1], [3, 3], [4, 1]]
    expect { board.take_out(*remove_these) }.to raise_error(MustTakeFromOneRow)
  end
end

def make_board(*args)
  RubiesBoard.new(*args)
end
