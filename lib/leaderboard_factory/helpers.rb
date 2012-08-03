module LeaderboardFactory
  # This system is in the most flux. These are some helpers that I found very, ahem, *helpful*.
  # I'm just not sure I'm sold on the API, and I know that there will be more.
  module Helpers
    def board_name name, key = nil
      name = name.gsub('_', '-')
      name += "-#{context.send(key)}" if key
      name
    end

    # Takes the top item off of the pivot and optionally passes the result through a callable mapper.
    #
    # @param leaderboard [Symbol] the name of the leaderboard
    # @param options [Hash] +:mapper+ is the only unique option, other per +#pivot+
    #
    # Example
    #
    #    leaderboards.top(:personal_bests) # => [16.0, ['Event ID 1', 'Event ID 3']]
    #    leaderboards.top(:personal_bests, mapper: Proc.new do |score, bests|
    #      { high_score: score.to_i, tied: bests.size, best_events: bests }
    #    end) # => { high_score: 16, tied: 2, best_events: ['Event ID 1', 'Event ID 3'] }
    def top leaderboard, options = {}
      result = pivot(leaderboard, options).first
      if options[:mapper]
        options[:mapper].call(*result)
      else
        result
      end
    end

    # Take the leaderboard and pivot the data by the score.
    # By default it will group the members by their score.
    #
    # @param leaderboard [Symbol] the name of the leaderboard you want to pivot
    # @param options [Hash] (optional) tweak the output
    #
    # Available options
    #
    #   +:member_data+ whether or not to include member data
    #   +:score+ a callable object that will transform the score
    #   +:pluck+ the name of a +member_data+ attribute. If you don't want all of the data.
    #
    # Examples
    #
    #    leaderboards.pivot(:personal_bests) # => { 16.0 => ['Event ID 1', 'Event ID 3'], 14.2 => ['Event ID 2'] }
    #    leaderboards.pivot(:personal_bests, member_data: true)
    #       # => { 16.0 => [{ 'event_name' => 'My Event Name', 'timestamp' => '12323425' },
    #                       { 'event_name' => 'My Third Attempt', 'timestamp' => '12323488' } ], ...
    #    leaderboards.pivot(:personal_bests, member_data: true, pluck: 'event_name')
    #       # => { 16.0 => ['My Event Name', 'My Third Attempt'], 14.2 => ['Followup'] }
    #    leaderboards.pivot(:personal_bests, score: Proc.new { |s| s.to_i })
    #       # => { 16 => ['Event ID 1', 'Event ID 3'], 14 => ['Event ID 2'] }
    def pivot leaderboard, options
      lb_options = {}
      if options[:member_data]
        lb_options.merge!(with_member_data: true)
      end
      context.send(leaderboard).all_members(lb_options).inject({}) do |buf, member|
        key = options[:score] ? options[:score].call(member[:score]) : member[:score]
        buf[key] ||= []
        item = if options[:pluck]
          member[:member_data][options[:pluck]]
        elsif options[:member_data]
          member[:member_data]
        else
          member[:member]
        end
        buf[key] << item
        buf
      end
    end

    # returns the given leaderboard
    #
    # @param leaderboard [Symbol] the name of the leaderboard you want
    #
    # Example
    #
    #    leaderboards.get(:personal_bests) # => Leaderboard
    def get leaderboard
      context.send(leaderboard)
    end

  end
end