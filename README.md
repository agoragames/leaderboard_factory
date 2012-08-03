# LeaderboardFactory

Helpful tools for defining a bunch of leaderboards associated with your objects. Builds on the [leaderboard](https://github.com/agoragames/leaderboard) gem.

## Installation

Add this line to your application's Gemfile:

    gem 'leaderboard_factory'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install leaderboard_factory

You'll need to tell it how to find Redis. Configure this on the module:

```ruby
LeaderboardFactory.redis = Redis.new
# or
LeaderboardFactory.configure do |c|
  c.redis = Redis.new(db: 15)
end
```

## Usage

Let's start with an example:

```ruby
class Player
  include LeaderboardFactory

  attr_accessor :id

  leaderboard 'game_duration', :id
  leaderboard 'maps_by_wins', :id
  collection_leaderboard 'best_finishes', { reverse: true }
end
```

What we've done here is define two leaderboards that are scoped to a player's ID, and one that applies to the entire collection of players. This latter one also ranks things in reverse order--there are two optional parameters to both methods, both hashes, and both are simply passed along to the leaderboard gem. The first is the leaderboard options, the second any specific redis options--if you need to pass along something specific for, say, a leaderboard in a different Redis instance. Check out the [leaderboard](https://github.com/agoragames/leaderboard) gem documentation for more details.

Let's look at how to use these.

```ruby
p = Player.new
p.id = 1234

p.game_duration # => <Leaderboard @leaderboard_name="game-duration-1234">
game_id = 1234
game_duration = 2345
p.rank_game_duration game_id, game_duration # => ["OK"]
p.game_duration.all_members # => [...]

Player.best_finishes # => <Leaderboard @leaderboard_name="best-finishes">
Player.rank_best_finishes p.id, 3, { player_name: "Bob" } # => ["OK", true]
Player.best_finishes.all_members(with_member_data: true) # etc etc
```

As you can see, we have a handy accessor that returns our leaderboard, and we even have a handy shortcut to add (*rank* in leaderboard parlance) new items to the board.

You can examine the options for any defined leaderboard via `Player.leaderboard_specs`.

There is a nascent and evolving set of helpers that you can access via `Player.leaderboards`--check out the helpers.rb file for more details there. These helpers will probably change.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright (c) 2012 Matt Wilson. See LICENSE for further details.