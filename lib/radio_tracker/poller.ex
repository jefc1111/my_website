defmodule RadioTracker.Poller do
  alias RadioTracker.Schemas.Track
  alias RadioTracker.Schemas.Play
  alias RadioTracker.Repo
  alias RadioTracker.DataAcquisition.RadioApi

  require Logger
  require Periodic
  require String
  @moduledoc """
  Documentation for `SixMusic`.
  """

  # Twitter's 'elevated access' API limit is 2_000_000 tweets pulled per month.
  # It does not appear to be possible to pull fewer than 5 in one go.
  # This results in an average of pulling 5 tweets around every 7.5 seconds.
  # The dormant phase and slow poll phase mean it would probably be possible to poll more
  # frequently. But every 7.5 seconds is probably enough anyway.
  # Supporting other radio stations may impact how best to do this.
  @twitter_poll_interval_secs 8
  @slow_poll_phase_multiplier 2
  @dormant_secs_after_last_play 60
  @slow_poll_secs_after_dormant 30

  # The idea is, after the track changes, you go for some time (@dormant_secs_after_track_change) before starting to poll again,
  # then for some further period of time (@slow_poll_secs_after_dormant) you poll at a less regular interval which is defined
  # by @twitter_poll_interval_secs * @slow_poll_phase_multiplier (i.e. 5 * 2 = poll every 10 secconds during the 'slow poll phase')

  def start_job(run_spec) do
    Periodic.start_link(
      # https://elixirforum.com/t/crashes-in-periodic-after-a-code-reload/35865
      run: run_spec,
      # @todo: when a new track is detected, there's no need to be polling every 5 seconds straight away. Maybe wait 30 seconds, then poll
      # every 10 seconds, then at 60 seconds start going every 5 seconds again. Bit unnecessarily fancy I guess, but kinda cool.
      every: :timer.seconds(@twitter_poll_interval_secs)
    )
  end

  defguard is_in_slow_poll_phase?(seconds_elapsed)
    when seconds_elapsed < @dormant_secs_after_last_play + @slow_poll_secs_after_dormant
    and seconds_elapsed >= @dormant_secs_after_last_play

  def handle_poll() do
    qty_tracks = Repo.aggregate(Track, :count, :id)

    cond do
      qty_tracks === 0 -> RadioApi.poll(nil) # Must have an empyy tracks table
      true ->
        last_play = Play.last_inserted

        seconds_since_last_play = Timex.diff(DateTime.utc_now, last_play.inserted_at, :seconds)

        case seconds_since_last_play do
          seconds_since_last_play when seconds_since_last_play < @dormant_secs_after_last_play ->
            {:noreply, "Not polling - current track only started less than a minute ago"}
          seconds_since_last_track when is_in_slow_poll_phase?(seconds_since_last_track)
            and rem(seconds_since_last_track, @slow_poll_phase_multiplier * @twitter_poll_interval_secs) === 0 ->
                RadioApi.poll(last_play)
          _ -> RadioApi.poll(last_play)
        end
    end
  end
end
