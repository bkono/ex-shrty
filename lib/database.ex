use Amnesia

defdatabase Shrty.Database do
  deftable ShrtUrl, [{:id, autoincrement}, :url, :hashid, :views], type: :ordered_set, index: [:url, :hashid] do
    @type t :: %ShrtUrl{id: integer, url: String.t, hashid: String.t, views: integer}

    def viewed!(shrturl) do
      %{shrturl | views: shrturl.views + 1 } |> ShrtUrl.write
    end
  end
end
