use Amnesia

defdatabase Shrty.Database do
  deftable ShrtUrl, [{:id, autoincrement}, :url, :hashid], type: :ordered_set, index: [:url, :hashid] do
    @type t :: %ShrtUrl{id: integer, url: String.t, hashid: String.t}
  end
end
