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

  it "verifies that RubiesBoard respond to picture method" do
    board.should respond_to :picture
  end

  it "verifies that RubiesBoard does not respond to initialize board" do
    board.should_not respond_to :initialize_board
  end

  it "verifies that RubiesBoard does not respond to fill column (mutator)" do
    board.should_not respond_to :fill_column
  end

  it "verifies that RubiesBoard does not respond to fill method (mutator)" do
    board.should_not respond_to :fill
  end

  it "verifies that RubiesBoard does not respond to empty method (mutator)" do
    board.should_not respond_to :empty
  end

  it "verifies that RubiesBoard responds to take out method" do
    board.should respond_to :take_out
  end

  it "verifies that RubiesBoard responds to empty? predicate" do
    board.should respond_to :empty?
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

  it "verifies that exceptions are prioritize correctly" do
    remove_these = [[1, 1], [1, 5]]
    expect { board.take_out(*remove_these) }.to raise_error(OutOfBoard)
  end

  it "verifies that MustTakeFromOneRow is with higher priority than RubiesNotConnected" do
    remove_these = [[3, 1], [3, 3], [4, 1]]
    expect { board.take_out(*remove_these) }.to raise_error(MustTakeFromOneRow)
  end

  it "says that the picture of the board is in 5 lines" do
    board.picture.count("\n").should eq 4
  end

  it "says that the picture of the small_board is with 2 lines (rows)" do
    small_board.picture.count("\n").should eq 1
  end

  it "says that the rubies on the board are within in (15..30) range" do
    board.picture.count('x').should be_between(15, 30)
  end

  it "says that the rubies on the small_board are within (3..6) range" do
    small_board.picture.count('x').should be_between(3, 6)
  end

  it "illustrates when we take rubies off the board the picture changes" do
    rubies_count_before = board.picture.count('x')
    board.take_out([3, 1], [3, 2], [3, 3])
    rubies_count_after  = board.picture.count('x')
    rubies_count_before.should eq rubies_count_after + 3
  end
end

def make_board(*args)
  RubiesBoard.new(*args)
end
