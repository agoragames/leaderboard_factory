require 'rspec'
require 'leaderboard_factory'
LeaderboardFactory.redis = Redis.new(db: 15)

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

end
