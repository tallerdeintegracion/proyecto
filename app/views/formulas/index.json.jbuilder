json.array!(@formulas) do |formula|
  json.extract! formula, :id, :sku, :descripcion, :lote, :unidad, :skuIngerdiente, :ingrediente, :requerimiento, :unidadIngrediente, :precioIngrediente
  json.url formula_url(formula, format: :json)
end
