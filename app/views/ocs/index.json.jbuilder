json.array!(@ocs) do |oc|
  json.extract! oc, :id, :oc, :estados, :canal, :factura, :pago, :sku, :cantidad
  json.url oc_url(oc, format: :json)
end
