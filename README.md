# Geoff's BBC 6 Music Radio Tracker

A 'now playing' app with bells on. 

Shows current and recently played songs and provides a button for each one which can be clicked in the event that the song is pleasing to the listener's ears.

I am building this to solve a specific use case I have;
"As a listener, I want to be able to easily note that I like a song so that later on and I can review these preferences and integrate then into my playlists elsewhere (i.e. Spotify)"

I also wanted a little project I could use as a way of learning some more Elixir / Phoenix Framework (https://www.phoenixframework.org/).

It's not so little now. _Big surprise_. 

Since there aren't really any users, I'm currently developing it scrappily and recklessly promoting half-baked features ot 'production'. 

## Roadmap
- User accounts (in progress)
- Auth. Show 'now playing' view for unauth'd users with a total (all users) of 'likes'
- For logged in users, show some sort of split of 'I like' vs. 'other people like'
- Add date range controls
- Spotify integration: Ability to send recently liked songs as a playlist to Spotify 
- Social features - ability to recommend to others

## How to run in local dev
You would want to install elixir. This is the output of `elixir -v` for me:

    Erlang/OTP 25 [erts-13.1.2] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [jit:ns]

    Elixir 1.14.0 (compiled with Erlang/OTP 25)

Also you will need postgres. The app is configured in dev to find postgres at localhost on the usual port. See `confg/dev.exs` for user/pass etc...

Once you have the above in place and have cloned the repo, do `mix phx.server`. I'm certain it won't work, but if we're lucky it might tell you what to do next (i.e. `mix deps.get`, `mix ecto.migrate`).