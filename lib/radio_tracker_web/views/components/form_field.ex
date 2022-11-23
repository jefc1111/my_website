defmodule RadioTrackerWeb.Components.FormField do
  use Phoenix.Component

  def input(assigns) do
    ~H"""
    <div class="field is-horizontal">
      <div class="field-label is-normal">
        <%= @label %>
      </div>
      <div>
        <div class="control">
          <%= @input %>
        </div>
        <%= @error_tag %>
      </div>
    </div>
    """
  end
end
