require "spec_helper"

describe "RubiesGame" do
  let (:board) { make_board }
  let (:game)  { make_game }

  it "verifies that game responds to board" do
    game.should respond_to :board
  end

  it "verifies that game responds to first_player" do
    game.should respond_to :first_player
  end

  it "verifies that game responds to second_player" do
    game.should respond_to :second_player
  end

  it "verifies that game responds to ai_difficulty" do
    game.should respond_to :ai_difficulty
  end

  it "verifies that game responds to last_move" do
    game.should respond_to :last_move
  end

  it "verifies that game doesnt respond to on_turn" do
    game.should_not respond_to :on_turn
  end

  it "winner function should return nil if there is no winner yet" do
    game.winner.should eq nil
  end

  def make_board(*args)
    RubiesBoard.new(*args)
  end

  def make_game(*args)
    args.empty? ? RubiesGame.new(make_board, 'first_player', 'second_player') : RubiesGame.new(*args)
  end
end
