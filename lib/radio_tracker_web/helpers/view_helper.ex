defmodule RadioTrackerWeb.ViewHelper do
  def pad_str(input, desired_length \\ 2, pad_char \\ 0) do
    d = desired_length + pad_char
    input ++ d
  end
end
