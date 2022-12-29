defmodule RadioTrackerWeb.LiveComponents.DateRangePicker do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div id="dateRangePickerHolder" phx-update="ignore" class="box">
      <input id="dateRangePicker" type="date" phx-hook="DateRangeHook">
    </div>
    """
  end

  def handle_event("set-date-range", data, socket) do
    send self(), {:date_range_change, data}

    {:noreply, socket}
  end
end
