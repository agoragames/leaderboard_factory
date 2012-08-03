require 'leaderboard_factory/helpers'

module LeaderboardFactory
  class HelperProxy
    include LeaderboardFactory::Helpers

    attr_accessor :context

    def initialize context
      self.context = context
    end

  end

  module HelperProxyMethods
    # Returns a contextualized helper instance so that one can use the helpers.
    def leaderboards
      HelperProxy.new(self)
    end
  end
end