defmodule Shrty.ShortenerControllerTest do
  use Shrty.ConnCase
  use Shrty.Database

  @test_url "https://github.com/bkono/dotfiles"

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "returns a token from a url" do
    conn = get conn, "/shrtn", url: @test_url
    resp = json_response(conn, 200)
    assert Map.has_key?(resp["data"], "token")
    assert Map.has_key?(resp, "links")
    assert Map.has_key?(resp["links"], "self")
    
    linked_url = URI.parse(resp["links"]["self"])
    assert linked_url.authority == URI.parse(url(conn)).authority
  end

  test "provides a link to the shortened url" do
    conn = get conn, "/shrtn", url: @test_url
    resp = json_response(conn, 200)

    assert Map.has_key?(resp, "links")
    assert Map.has_key?(resp["links"], "self")
  end

  test "sets the link back to the same host as the current webapp" do
    conn = get conn, "/shrtn", url: @test_url
    resp = json_response(conn, 200)

    linked_url = URI.parse(resp["links"]["self"])
    assert linked_url.authority == URI.parse(url(conn)).authority
  end

  test "redirects to url when given a valid token" do
    conn = get conn, "/shrtn", url: @test_url
    token = json_response(conn, 200)["data"]["token"]
    conn = get conn, "/#{token}"
    assert get_resp_header(conn, "location") == [@test_url]
  end

  test "returns a 404 when given an invalid token" do
    conn = get conn, "/abcasdjalkjsdklajsdklajkldsmakdsa"
    assert conn.status == 404
  end

  test "provides views count at the metrics endpoint" do
    conn = get conn, "/shrtn", url: "metrics_test_url"
    token = json_response(conn, 200)["data"]["token"]
    get conn, "/#{token}"

    conn = get conn, "/metrics/#{token}"
    result = json_response(conn, 200)["data"]
    assert result["token"] == token
    assert result["url"] == "metrics_test_url"
    assert result["views"] == 1
  end
end
