module LeaderboardFactory
  module Configuration
    # Redis instance
    attr_accessor :redis

    # yield self for block-style config
    #
    # LeaderboardFactory.configure { |c| c.redis = Redis.new(db: 15) }
    def configure
      yield self
    end
  end
end