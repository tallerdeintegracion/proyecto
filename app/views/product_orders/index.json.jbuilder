json.array!(@product_orders) do |product_order|
  json.extract! product_order, :id, :sku, :cantidad, :disponibe
  json.url product_order_url(product_order, format: :json)
end
