require 'rspec'
require 'leaderboard_factory'
LeaderboardFactory.redis = Redis.new(db: 15)

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before(:each) do
    LeaderboardFactory.redis.flushdb
  end

  config.after(:all) do
    LeaderboardFactory.redis.flushdb
    LeaderboardFactory.redis.quit
  end
end
