defmodule Shrty.ShortenerView do
  use Shrty.Web, :view

  def render("show.json", %{token: token}) do
    %{
      links: %{self: shortener_url(Shrty.Endpoint, :show, token)},
      data: %{token: token}
    }
  end
end
