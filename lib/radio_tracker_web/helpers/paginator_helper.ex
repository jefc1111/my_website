defmodule RadioTrackerWeb.Helpers.PaginatorHelper do
  @moduledoc """
  Renders the pagination with a previous button, the pages, and the next button.

  From https://dev.to/ricardoruwer/create-a-paginator-using-elixir-and-phoenix-1hnk
  """

  use Phoenix.HTML

  def render(_conn, data, class: class) do
    first = prev_button(data)
    pages = page_buttons(data)
    last = next_button(data)

    content_tag(:ul, [first, pages, last], class: class)
  end

  defp prev_button(data) do
    page = data.current_page - 1
    disabled = data.current_page == 1
    params = build_params(page)

    content_tag(:li, disabled: disabled) do
      link to: "?#{params}", rel: "prev", class: "pagination-previous" do
        "Previous"
      end
    end
  end

  defp page_buttons(data) do
    for page <- 1..data.total_pages do
      class = if data.current_page == page, do: "active"
      disabled = data.current_page == page
      params = build_params(page)

      content_tag(:li, class: class, disabled: disabled) do
        link(page, to: "?#{params}", class: "pagination-link")
      end
    end
  end

  defp next_button(data) do
    page = data.current_page + 1
    disabled = data.current_page >= data.total_pages
    params = build_params(page)
    content_tag(:li, disabled: disabled) do
      link to: "?#{params}", rel: "next",  class: "pagination-next" do
        "Next"
      end
    end
  end

  defp build_params(page) do
    %{page: page} |> URI.encode_query()
  end

  # This version had a bug where the URL ended up with two page seletors in
  # defp build_params(conn, page) do
  #  conn.query_params |> Map.put(:page, page) |> URI.encode_query()
  # end
end
