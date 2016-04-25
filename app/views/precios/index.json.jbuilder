json.array!(@precios) do |precio|
  json.extract! precio, :id, :sku, :descripcion, :precioUnitario
  json.url precio_url(precio, format: :json)
end
