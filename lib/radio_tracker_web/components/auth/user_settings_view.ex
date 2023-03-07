defmodule RadioTrackerWeb.UserSettingsView do
  use RadioTrackerWeb, :html

  import RadioTrackerWeb.Components.FormField
  import RadioTrackerWeb.Components.ButtonWithIcon
  import RadioTrackerWeb.Components.FormValidationFail
  import RadioTrackerWeb.Components.Form.Wrapper
  import RadioTrackerWeb.Components.Icon

  embed_templates "../templates/auth/user_settings/*"
end
