defmodule Shrty.ShortenerControllerTest do
  use Shrty.ConnCase

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

#   test "lists all entries on index", %{conn: conn} do
#     conn = get conn, short_url_path(conn, :index)
#     assert json_response(conn, 200)["data"] == []
#   end
#
#   test "shows chosen resource", %{conn: conn} do
#     short_url = Repo.insert! %ShortUrl{}
#     conn = get conn, short_url_path(conn, :show, short_url)
#     assert json_response(conn, 200)["data"] == %{"id" => short_url.id,
#       "name" => short_url.name}
#   end
#
#   test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
#     assert_raise Ecto.NoResultsError, fn ->
#       get conn, short_url_path(conn, :show, -1)
#     end
#   end
#
end
