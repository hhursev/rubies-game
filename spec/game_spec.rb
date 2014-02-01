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

  describe "human_move method" do
    it "give incorrect move to human_move method" do
      expect { game.human_move("3 1, 3 2, 3 4") }.to raise_error
    end

    it "gives correct move to human_move and board is updated" do
      game.human_move("2 1, 2 2")
      game.board.filled_at?(2, 1).should eq false
      game.board.filled_at?(2, 2).should eq false
    end

    it "says when the move is incorrect is the same player on turn" do
      on_turn_before = game.on_move_is
      expect { game.human_move("3 1, 3 3") }.to raise_error
      on_turn_after = game.on_move_is

      on_turn_before.should eq on_turn_after
    end

    it "says when move is correct the on move is the other player" do
      on_turn_before = game.on_move_is
      game.human_move("3 1, 3 2")
      on_turn_after = game.on_move_is

      on_turn_before.should_not eq on_turn_after
    end
  end

  describe "last move attribute" do
    it "verifies that last_move is updated" do
      game.last_move.should eq ""
      game.human_move("3 1, 3 2")
      game.last_move.should eq "first_player moved: [[3, 1], [3, 2]]"
    end

    it "verifies that last_move is kept intact when wrong move is submitted" do
      game.human_move("3 1, 3 2")
      expect { game.human_move("2 1, 3 3") }.to raise_error

      game.last_move.should eq "first_player moved: [[3, 1], [3, 2]]"
    end

    it "verifies that last_move is rewritten when it is changed" do
      game.human_move("3 1, 3 2")
      game.human_move("1 1")

      game.last_move.should eq "second_player moved: [[1, 1]]"
    end
  end

  it "winner function should return nil if there is no winner yet" do
    game.winner.should eq nil
  end
end


def make_board(*args)
  RubiesBoard.new(*args)
end

def make_game(*args)
  args.empty? ? RubiesGame.new(make_board, 'first_player', 'second_player') : RubiesGame.new(*args)
end