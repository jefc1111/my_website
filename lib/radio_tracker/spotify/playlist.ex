defmodule RadioTracker.Spotify.Playlist do
  use HTTPoison.Base
  use Flop

  alias RadioTracker.Spotify.Authorization

  defstruct id: "unknown", name: "No name"

  @page_size 10

  def get_user_playlists(user, params) do
    {page, ""} = case params do
      %{"page" => p} -> p
      _ -> "1"
    end |> Integer.parse()

    query_params = %{
      "limit" => @page_size,
      "offset" => page * @page_size
    }

    query_str = URI.encode_query(query_params)

    {:ok, result} = Authorization.do_user_req(user, "https://api.spotify.com/v1/me/playlists?#{query_str}")

    playlists_as_structs = result["items"] |> Enum.map(
      fn item -> %__MODULE__{
        id: item["id"],
        name: item["name"]
      } end
    )

    total_pages = ceil(result["total"] / @page_size)

    flop_meta = %Flop.Meta{
      page_size: @page_size,
      current_page: page,
      total_pages: total_pages,
      total_count: result["total"],
      has_previous_page?: page > 1,
      has_next_page?: page < total_pages,
      next_page: page + 1,
      previous_page: page - 1
    }

    IO.inspect(flop_meta)

    {:ok, {playlists_as_structs, flop_meta}}
  end
end
