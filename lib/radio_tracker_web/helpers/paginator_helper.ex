defmodule RadioTrackerWeb.Helpers.PaginatorHelper do
  @moduledoc """
  Renders the pagination with a previous button, the pages, and the next button.

  From https://dev.to/ricardoruwer/create-a-paginator-using-elixir-and-phoenix-1hnk
  """

  use Phoenix.HTML

  def render(data, class: class) do
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

  # prev 1 2 ... 14 15 *16* 17 18 19 ... 56 57 next
  defp render_page_link?(page_num, qty_pages, current_page) do
    page_num < 3 # always show first two page links
    || page_num > (qty_pages - 2) # always show last two page links
    || (page_num > current_page - 3 && page_num < current_page + 3) # current page and two either side
  end

  defp page_buttons(data) do
    for page <- 1..data.total_pages do
      case render_page_link?(page, data.total_pages, data.current_page) do
        true ->
          class = if data.current_page == page, do: "active"
          disabled = data.current_page == page
          params = build_params(page)

          content_tag(:li, class: class, disabled: disabled) do
            link(page, to: "?#{params}", class: "pagination-link")
          end
        _ -> case page do
          page when page in [4, data.total_pages - 4] -> "....."
          _ -> ""
        end
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
