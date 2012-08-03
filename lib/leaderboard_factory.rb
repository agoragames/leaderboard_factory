require 'leaderboard'
require 'leaderboard_factory/configuration'
require 'leaderboard_factory/helper_proxy'
require 'leaderboard_factory/version'
require 'active_support/inflector'
require 'active_support/concern'
require 'active_support/core_ext/class/attribute'

module LeaderboardFactory
  extend Configuration
  extend ActiveSupport::Concern

  included do
    class_attribute :leaderboard_specs
    self.leaderboard_specs = {
      instance: {},
      collection: {}
    }

    include HelperProxyMethods
    extend HelperProxyMethods
  end

  module ClassMethods
    # Defines a new leaderboard that will be scoped to some unique property on the object instance.
    # Use this if you want to, say, track a specific player's personal bests, or some other
    #   stat that is specific to the individual.
    # This method defines an accessor that will return the leaderboard, as well as a shorthand
    #   method for ranking a new item in the leaderboard
    #
    # @param board [String] the name of the leaderboard
    # @param scope_key [String/Symbol] the name of an attribute on the instance that will scope the leaderboard.
    # @param options [Hash] optional; these are passed along to the leaderboard object
    # @param redis_options [Hash] optional; these are also passed along to the leaderboard object
    #
    # Example
    #
    #    class Player < ActiveRecord::Base
    #      include LeaderboardFactory
    #      leaderboard 'maps_by_wins', :id
    #    end
    #
    #    p = Player.new(id: 77)
    #    p.maps_by_wins # => the player's personal maps leaderboard
    #    p.rank_map_by_wins map.name, 33, { map_id: 42 } # => ["OK", true]
    def leaderboard board, scope_key, options = {}, redis_options = {}
      self.leaderboard_specs[:instance][board] = {
        key: scope_key,
        options: options,
        redis_options: redis_options
      }

      define_methods board, :instance
    end

    # As +leaderboard+, but on the class rather than the instance.
    # it does not take a +scope_key+ parameter, but all other functionality is the same.
    #
    # @param board [String] the name of the leaderboard
    # @param scope_key [String/Symbol] the name of an attribute on the instance that will scope the leaderboard.
    # @param options [Hash] optional; these are passed along to the leaderboard object
    # @param redis_options [Hash] optional; these are also passed along to the leaderboard object
    #
    # Example
    #
    #    class Player < ActiveRecord::Base
    #      include LeaderboardFactory
    #      collection_leaderboard 'strength_of_schedule'
    #    end
    #
    #    Player.strength_of_schedule # => the leaderboard object
    #    Player.rank_strength_of_schedule 232, 66.3, { player_name: 'Bob' } # => ["OK", true]
    def collection_leaderboard board, options = {}, redis_options = {}
      self.leaderboard_specs[:collection][board] = {
        options: options,
        redis_options: redis_options
      }

      define_methods board, :collection, 'self.'
    end

    # Method what actually does the defining.
    def define_methods board, type = :instance, prefix = ''
      singluar_object, *remainder_of_name = board.split("_")
      singluar_object = singluar_object.singularize
      accessor_method_name = ([singluar_object] + remainder_of_name).join("_")

      class_eval <<-METHODS, __FILE__, __LINE__
        def #{prefix}#{board}
          return @#{board} if @#{board}
          options               = leaderboard_specs[:#{type}]['#{board}'][:options]
          redis_options         = leaderboard_specs[:#{type}]['#{board}'][:redis_options]
          redis_key             = leaderboard_specs[:#{type}]['#{board}'][:key]

          redis_options.merge!({
            redis_connection: LeaderboardFactory.redis
          })

          @#{board} = Leaderboard.new( leaderboards.board_name('#{board}', redis_key),
                                       Leaderboard::DEFAULT_OPTIONS.merge(options),
                                       redis_options )
        end

        def #{prefix}rank_#{accessor_method_name} object, rank, member_data = nil
          #{board}.rank_member object, rank, member_data
        end
      METHODS
    end
  end

  # instance methods would go here...

end