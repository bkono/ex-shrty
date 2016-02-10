defmodule Shrty.Router do
  use Shrty.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/shrtn", Shrty do
    pipe_through :api
    get "/", ShortenerController, :create
  end

  scope "/", Shrty do
    pipe_through :browser # Use the default browser stack

    get "/:token", ShortenerController, :show
    get "/metrics/:token", ShortenerController, :metrics
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Shrty do
  #   pipe_through :api
  # end
end
