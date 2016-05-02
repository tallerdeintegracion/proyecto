json.array!(@ocs) do |oc|
  json.extract! oc, :id, :oc, :estados
  json.url oc_url(oc, format: :json)
end
