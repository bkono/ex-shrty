defmodule Shrty do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    :application.set_env(:mnesia, :dir, mnesia_dir)
    Amnesia.start

    children = [
      # Start the endpoint when the application starts
      supervisor(Shrty.Endpoint, []),
      # Start the Ecto repository
      worker(Shrty.Repo, []),
      worker(Shrty.Shortener, [[name: Shrty.Shortener]])
      # Here you could define other workers and supervisors as children
      # worker(Shrty.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shrty.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Shrty.Endpoint.config_change(changed, removed)
    :ok
  end

  def mnesia_dir do
    String.to_atom Application.get_env(:shrty, :mnesia_dir)
  end
end
