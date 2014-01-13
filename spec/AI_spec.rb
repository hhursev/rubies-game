require "spec_helper"

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
