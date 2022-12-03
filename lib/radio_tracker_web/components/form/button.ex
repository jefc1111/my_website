defmodule RadioTrackerWeb.Components.ButtonWithIcon do
  use Phoenix.Component

  import RadioTrackerWeb.Components.Icon

  attr :class, :string, default: nil
  attr :icon_name, :string, default: nil
  attr :icon_type, :string, default: nil
  attr :text, :string, default: nil
  attr :type, :string, default: nil

  def button_with_icon(assigns) do
    ~H"""
    <button type={ @type } class={ "button " <> @class }>
      <span class="icon">
        <.icon name={ @icon_name } type={ @icon_type } class="icon" />
      </span>
      <span><%= @text %></span>
    </button>
    """
  end
end
