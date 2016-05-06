json.array!(@skus) do |sku|
  json.extract! sku, :id, :sku, :descripcion, :tipo, :grupoProyecto, :costoUnitario, :loteProduccion, :tiempoProduccion, :reservado
  json.url sku_url(sku, format: :json)
end
