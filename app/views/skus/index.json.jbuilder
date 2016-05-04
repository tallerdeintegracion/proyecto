json.array!(@skus) do |sku|
  json.extract! sku, :id, :sku, :descripcion, :tipo, :grupoProyecto, :unidades, :costoUnitario, :loteProduccion, :tiempoProduccion
  json.url sku_url(sku, format: :json)
end
