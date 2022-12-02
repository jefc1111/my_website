defmodule RadioTrackerWeb.Components.Form.Wrapper do
  use Phoenix.Component

  slot :inner_block, required: true

  def form_wrapper(assigns) do
    ~H"""
    <div class="box columns is-desktop">
      <div class="column is-quarter">
      </div>
      <div class="column is-half">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="column is-quarter">
      </div>
    </div>
    """
  end
end
