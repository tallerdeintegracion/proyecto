json.array!(@stockfechas) do |stockfecha|
  json.extract! stockfecha, :id, :fecha, :sku, :cantidad
  json.url stockfecha_url(stockfecha, format: :json)
end
