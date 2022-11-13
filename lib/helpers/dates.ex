
defmodule RadioTracker.Helpers.Dates do
  use Timex

  def human_readable(timestamp) do
    # Must be a better way!
    secs_to_shift = Timex.Timezone.total_offset(Timex.Timezone.local)

    timex_res = timestamp
    |> Timex.shift(seconds: secs_to_shift)
    |> Timex.format("{h24}:{m}:{s} {D}/{M}")

    case timex_res do
      {:ok, dt} -> dt
      _ -> "Not recognised"
    end
  end
end
