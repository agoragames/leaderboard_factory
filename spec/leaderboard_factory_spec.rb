require 'spec_helper'

describe LeaderboardFactory do
  let(:test_harness) {
    Class.new do
      attr_accessor :id
      include LeaderboardFactory
    end
  }

  it "isn't borked" do
    test_harness.included_modules.should include(LeaderboardFactory)
  end

  context 'configuration' do
    it 'has a redis accessor' do
      LeaderboardFactory.should respond_to(:redis)
    end
    it "uses the redis that is configured" do
      LeaderboardFactory.redis.client.db.should == 15
    end
  end

  describe ".leaderboard" do
    it "defines a connection to a leaderboard object" do
      test_harness.should respond_to(:leaderboard)
      test_harness.class_eval do
        leaderboard 'fu_manchu', :id
      end
      test_harness.leaderboard_specs[:instance]['fu_manchu'].should include({
        key: :id,
        options: {}
      })
    end
    it "creates a factory method that returns said leaderboard" do
      test_harness.class_eval do
        leaderboard 'fu_manchu', :id
      end
      instance = test_harness.new

      instance.fu_manchu.should be_a_kind_of(Leaderboard)
    end
    it "uses the second parameter to namespace the leaderboard" do
      test_harness.class_eval do
        leaderboard 'fu_manchu', :id
      end
      instance = test_harness.new
      instance.id = 'haha'
      leaderboard = instance.fu_manchu
      leaderboard.leaderboard_name.should == 'fu-manchu-haha'
    end
    it "doesn't leak the abstraction" do
      klass = Class.new do
        attr_accessor :id
        include LeaderboardFactory
        leaderboard 'garlic', :id
      end

      klass.new.leaderboard_specs[:instance].keys.should include('garlic')
      test_harness.new.leaderboard_specs[:instance].should be_empty
    end
    it "is connected to the configured redis instance" do
      test_harness.class_eval do
        leaderboard 'fu_manchu', :id
      end
      redis = test_harness.new.fu_manchu.instance_variable_get(:@redis_connection)
      redis.should === LeaderboardFactory.redis
    end
    it "adds a convience accessor based on the singularized object name, e.g. maps_by_wins => rank_map_by_wins" do
      test_harness.class_eval do
        leaderboard 'maps_by_wins', :id
      end
      instance = test_harness.new

      instance.should respond_to(:rank_map_by_wins)
      instance.rank_map_by_wins 'map', 3
      instance.maps_by_wins.all_members.should include({:member=>"map", :rank=>1, :score=>3.0})
    end
    describe "this convience accessor" do
      it "accepts an optional third parameter, which is member data" do
        test_harness.class_eval do
        leaderboard 'maps_by_wins', :id
      end
      instance = test_harness.new

      instance.rank_map_by_wins 'map', 3, { event_name: 'framulator 5000' }
      instance.maps_by_wins.all_members(with_member_data: true).should include({
        member: "map",
        rank: 1,
        score: 3.0,
        member_data: {"event_name"=>"framulator 5000"}
      })
      end
    end
    it "can be overriden in the class" do
      klass = Class.new do
        attr_accessor :id
        include LeaderboardFactory
        leaderboard 'garlics_by_weight', :id

        def rank_garlic_by_weight
          "HA! HA!"
        end
      end

      klass.new.rank_garlic_by_weight.should == "HA! HA!"
    end
  end

  describe ".collection_leaderboard" do
    it "defines a connection to a leaderboard object" do
      test_harness.should respond_to(:collection_leaderboard)
      test_harness.class_eval do
        collection_leaderboard 'greatest_of_all_time'
      end
      test_harness.leaderboard_specs[:collection]['greatest_of_all_time'].should include({
        options: {}
      })
    end
    it "creates a factory method that returns said leaderboard" do
      test_harness.class_eval do
        collection_leaderboard 'greatest_of_all_time'
      end

      test_harness.greatest_of_all_time.should be_a_kind_of(Leaderboard)
    end
  end

end