defmodule Shrty.PageController do
  use Shrty.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
