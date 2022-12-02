defmodule RadioTrackerWeb.UserRegistrationView do
  use RadioTrackerWeb, :html

  import RadioTrackerWeb.Components.FormField
  import RadioTrackerWeb.Components.ButtonWithIcon
  import RadioTrackerWeb.Components.FormValidationFail

  embed_templates "../templates/auth/user_registration/*"
end
