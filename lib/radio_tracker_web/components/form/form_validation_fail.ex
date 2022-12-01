defmodule RadioTrackerWeb.Components.FormValidationFail do
  import RadioTrackerWeb.Components.Icon

  use Phoenix.Component

  attr :text, :string, default: "There was a problem with the input. Please check the errors below."

  def form_validation_fail(assigns) do
    ~H"""
    <div class="notification is-danger">
      <p>
        <.icon name="circle-info" type="solid" class="icon" />
        <%= @text %>
      </p>
    </div>
    """
  end
end
