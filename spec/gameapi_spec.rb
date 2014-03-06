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

class GameAPI
end

describe "GameAPIModule" do
  let (:board) { make_board custom_board: {[1, 1] => nil, [2, 1] => nil, [2, 2] => nil} }
  let (:game) { make_game }

  let(:dirs) { ["test_dir"] }


  before(:each) do
    FakeFS.activate!

    dirs.each do |path|
      Dir.mkdir path unless File.directory? path
    end

    @gameapi_class = GameAPI.new
    @gameapi_class.extend(RubiesGameAPI)
  end

  after(:each) do
    dirs.each do |path|
      FileUtils.rm_rf("#{path}/.", secure: true)
    end

    FakeFS.deactivate!
  end

  it "checks if API has method move_parser" do
    @gameapi_class.should respond_to :move_parser
  end

  it "checks if API has method array_representation_of" do
    @gameapi_class.should respond_to :array_representation_of
  end

  it "checks if API has method board_string" do
    @gameapi_class.should respond_to :board_string
  end

  it "checks if API has method save" do
    @gameapi_class.should respond_to :save
  end

  it "checks if API has method load_game" do
    @gameapi_class.should respond_to :load_game
  end

  it "checks if API has method saved_games_in" do
    @gameapi_class.should respond_to :saved_games_in
  end

  it "verifies that move_parser work the way it should" do
    @gameapi_class.move_parser("1 1, 1 2, 3 4").should eq [[1, 1], [1, 2], [3, 4]]
  end

  it "verifies that array_representation_of_board is working" do
    @gameapi_class.array_representation_of(board).should eq [[1], [1, 1]]
  end

  it "verifies that board_string method is working correctly" do
    @gameapi_class.board_string(board).should eq " x\nx x"
  end

  it "verifies that save game creates a new file" do
    @gameapi_class.save(game, 'test_file', 'test_dir')
    @gameapi_class.saved_games_in("test_dir").should eq ["test_file"]
  end

  it "verifies that load_game loads files succesfully saved before that" do
    game_played = game
    @gameapi_class.save(game_played, 'test_file', 'test_dir')
    game_loaded = @gameapi_class.load_game('test_dir', 'test_file')
    # another solution to this explicit checks is defining hash functions
    game_played.board.board.should eq game_loaded.board.board
    game_played.on_move_is.should eq game_loaded.on_move_is
    game_played.last_move.should eq game_loaded.last_move
  end

  it "verifies that saved_games_in directory returns all the files in a given dir" do
    @gameapi_class.save(game, 'test_file_1', 'test_dir')
    @gameapi_class.save(game, 'test_file_2', 'test_dir')
    @gameapi_class.saved_games_in('test_dir').should eq ["test_file_1", "test_file_2"]
  end

  def make_board(*args)
    RubiesBoard.new(*args)
  end

  def make_game(*args)
    args.empty? ? RubiesGame.new(make_board, "first_player", "second_player") : RubiesGame.new(*args)
  end
end

describe "RubiesPositionsToDraw" do
  RUBY_WIDTH      = 20
  RUBY_HEIGHT     = 100

  let (:board) { make_board custom_board: {[1, 1] => nil, [2, 1] => nil, [2, 2] => nil} }
  let (:game) { make_game board, "first_player", "second_player" }

  it "respond to rubies" do
    RubiesPositionsToDraw.new(game.board).should respond_to :rubies
  end

  it "initialize rubies hash for the ui" do
    rubies_hash_must_be = {
      [50, 10]=>{:position=>[1, 1], :status=>:untouched},
      [30, 130]=>{:position=>[2, 1], :status=>:untouched},
      [70, 130]=>{:position=>[2, 2], :status=>:untouched}
    }
    RubiesPositionsToDraw.new(game.board).rubies.should eq rubies_hash_must_be
  end

  it "initialize rubies hash for the ui with one taken" do
    game_instance = game
    game_instance.board.take_out([1, 1])
    rubies_hash_must_be = {
      [50, 10]=>{:position=>[1, 1], :status=>:taken},
      [30, 130]=>{:position=>[2, 1], :status=>:untouched},
      [70, 130]=>{:position=>[2, 2], :status=>:untouched}
    }
    RubiesPositionsToDraw.new(game_instance.board).rubies.should eq rubies_hash_must_be
  end

  def make_board(*args)
    RubiesBoard.new(*args)
  end

  def make_game(*args)
    args.empty? ? RubiesGame.new(make_board, "first_player", "second_player") : RubiesGame.new(*args)
  end
end
