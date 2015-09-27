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

  defp shrink(%{id: 0}, url) do
    Amnesia.transaction do
      case ShrtUrl.last do
        :badarg -> shrink(%{id: 1}, url)
        %ShrtUrl{id: next_id} -> shrink(%{id: next_id}, url)
      end
    end
  end

  defp shrink(%{id: next_id}, url_to_shrink) do
    Logger.info "Shrinking url: [ #{url_to_shrink} ]"
    Amnesia.transaction do
      query = ShrtUrl.where(url == url_to_shrink) |> Amnesia.Selection.values
      case query do
        [] ->
          token = Hashids.encode(@coder, next_id)
          %ShrtUrl{url: url_to_shrink, hashid: token} |> ShrtUrl.write
          Logger.info "... associated token: [ #{token} ] to [ #{url_to_shrink} ]"
          {%{id: next_id + 1}, token}
        [%ShrtUrl{hashid: token}] -> {%{id: next_id}, token}
        [_head = %ShrtUrl{hashid: token} | _tail] -> {%{id: next_id}, token}
      end
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
