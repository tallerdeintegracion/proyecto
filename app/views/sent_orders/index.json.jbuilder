json.array!(@sent_orders) do |sent_order|
  json.extract! sent_order, :id, :oc, :sku, :cantidad, :estado, :fechaEntrega
  json.url sent_order_url(sent_order, format: :json)
end
