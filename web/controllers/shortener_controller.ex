defmodule Shrty.ShortenerController do
  use Shrty.Web, :controller

  def create(conn, %{"url" => url}) do
    token = Shrty.Shortener.shrink(url)
    render(conn, "show.json", token: token)
  end

  def show(conn, %{"token" => token}) do
    redirect_to_url(conn, Shrty.Shortener.expand(token))
  end

  defp redirect_to_url(conn, nil) do
    conn
    |> put_status(:not_found)
    |> render(Shrty.ErrorView, "404.html")
  end

  defp redirect_to_url(conn, url), do: redirect(conn, external: url)
end
