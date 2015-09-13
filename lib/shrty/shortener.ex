defmodule Shrty.Shortener.State do
  defstruct id: 0, urls: %{}
end

defmodule Shrty.Shortener do
  use GenServer
  alias Shrty.Shortener.State

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

  def shrink(state, url) do
    state = %{state | id: state.id + 1}
    token = Hashids.encode(@coder, state.id)
    urls = Map.put(state.urls, token, url)
    {%{state | urls: urls}, token}
  end

  def expand(state, token), do: Map.get(state.urls, token)
end
