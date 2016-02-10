defmodule Shrty.ShortenerController do
  use Shrty.Web, :controller
  require Logger

  def create(conn, %{"url" => url}) do
    token = Shrty.Shortener.shrink(url)
    render(conn, "show.json", token: token)
  end

  def show(conn, %{"token" => token}) do
    redirect_to_url(conn, token, Shrty.Shortener.expand(token))
  end

  defp redirect_to_url(conn, _token, nil) do
    conn
    |> put_status(:not_found)
    |> render(Shrty.ErrorView, "404.html")
  end

  defp redirect_to_url(conn, token, url) do
    Logger.info "Valid token [ #{token} ], redirecting to: [ #{url} ]"
    redirect(conn, external: url)
  end
end
