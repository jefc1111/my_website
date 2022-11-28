defmodule RadioTrackerWeb.Components.ButtonWithIcon do
  use Phoenix.Component

  import RadioTrackerWeb.Components.Icon

  def button_with_icon(assigns) do
    assigns = assign_new(assigns, :class, fn -> "" end)

    ~H"""
    <button class={ "button " <> @class }>
      <span class="icon">
        <.icon name={ @icon_name } type={ @icon_type } class="icon" />
      </span>
      <span><%= @text %></span>
    </button>
    """
  end
end
