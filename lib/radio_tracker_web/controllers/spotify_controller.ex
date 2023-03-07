defmodule RadioTrackerWeb.SpotifyController do
  use RadioTrackerWeb, :controller

  def index(conn, _params) do
    state = random_string(16);
    scope = "playlist-modify-private playlist-modify-public";

    query_params = %{
      "response_type" => "code",
      "client_id" => "f76ee05f7ce74d0cb5720962bae8b2d1",
      "scope" => scope,
      "redirect_uri" => "http://localhost:4000",
      "state" => state
    }

    query_str = URI.encode_query(query_params)

    IO.inspect(query_str)

    redirect(conn, external: "https://accounts.spotify.com/authorize?#{query_str}")

    # querystring.stringify({
    #   response_type: 'code',
    #   client_id: client_id,
    #   scope: scope,
    #   redirect_uri: redirect_uri,
    #   state: state
    # }));

#     query = %{"foo" => 1, "bar" => 2}
# URI.encode_query(query)
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end
end
