defmodule Shrty.ShortenerTest do
  use ExUnit.Case, async: true
  alias Shrty.Shortener

  @coder Hashids.new([salt: Application.get_env(:shrty, :hashids_salt)])
  @long_url "https://github.com/bkono/dotfiles"

  test "turns a url into a short token" do
    token = Shortener.shrink(@long_url)
    assert String.valid? token
    assert token != @long_url
  end
  
  test "shrink provides a valid hashid" do
    token = Shortener.shrink(@long_url)
    {:ok, decoded} = Hashids.decode(@coder, token)
    assert Enum.count(decoded) == 1
    assert is_number(hd(decoded))
  end

  test "expands a token back to its original url" do
    token = Shortener.shrink(@long_url)
    decoded_url = Shortener.expand(token)
    assert decoded_url == @long_url
  end

  test "returns the same token when shrinking the same url multiple times" do
    token1 = Shortener.shrink(@long_url)
    token2 = Shortener.shrink(@long_url)

    assert token1 == token2
  end
end
