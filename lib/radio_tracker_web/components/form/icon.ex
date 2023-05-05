defmodule RadioTrackerWeb.Components.Icon do
  use Phoenix.Component

  attr :name, :string, default: ""
  attr :class, :string, default: ""
  attr :type, :string, default: ""

  def icon(assigns) do
    ~H"""
    <FontAwesome.LiveView.icon name={@name} type={@type} class={@class} />
    """
  end
end
