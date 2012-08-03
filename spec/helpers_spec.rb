require 'spec_helper'

module LeaderboardFactory
  describe Helpers do
    let(:kontext) {
      mock
    }
    let(:proxy) {
      LeaderboardFactory::HelperProxy.new(kontext)
    }

    describe "#board_name" do
      it "returns a good name for the leaderboard" do
        proxy.board_name('garlics_by_weight').should == 'garlics-by-weight'
      end
      it "takes an optional second parameter which will be used to uniqify the name" do
        kontext.should_receive(:id).and_return(1234)
        proxy.board_name('personal_best_garlics', :id).should == 'personal-best-garlics-1234'
      end
    end
  end
end