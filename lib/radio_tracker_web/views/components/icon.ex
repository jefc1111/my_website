defmodule RadioTrackerWeb.Components.Icon do
  use Phoenix.Component

  def icon(assigns) do
    ~H"""
    <FontAwesome.LiveView.icon name={@name} type={@type} class={@class} />
    """
  end
end
