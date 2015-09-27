require Logger

defmodule Shrty.Shortener.State do
  defstruct id: 0
end

defmodule Shrty.Shortener do
  use GenServer
  alias Shrty.Shortener.State
  use Amnesia
  use Shrty.Database

  @name __MODULE__
  @coder Hashids.new([salt: Application.get_env(:shrty, :hashids_salt), min_len: 2])

  # Client
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def shrink(url) do
    GenServer.call(@name, {:shrink, url})
  end

  def expand(token) do
    GenServer.call(@name, {:expand, token})
  end

  # Server
  def init(_args) do
    {:ok, %State{}}
  end

  def handle_call({:shrink, url}, _from, state) do
    {state, token} = shrink(state, url)
    {:reply, token, state}
  end

  def handle_call({:expand, token}, _from, state) do
    {:reply, expand(state, token), state}
  end

  defp shrink(state, url) do
    Logger.info "Shrinking url: [ #{url} ]"
    %{id: next_id} = state
    token = Hashids.encode(@coder, next_id)
    Amnesia.transaction do
      %ShrtUrl{url: url, hashid: token} |> ShrtUrl.write
      Logger.info "... associated token: [ #{token} ] to [ #{url} ]"
      {%{id: next_id + 1}, token}
    end
  end

  defp expand(_state, token) do
    Amnesia.transaction do
      case ShrtUrl.where(hashid == token) |> Amnesia.Selection.values do
        [%{url: url}] -> url
        [] -> nil
      end
    end
  end
end
