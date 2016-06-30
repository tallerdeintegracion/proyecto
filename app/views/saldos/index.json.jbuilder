json.array!(@saldos) do |saldo|
  json.extract! saldo, :id, :fecha, :monto
  json.url saldo_url(saldo, format: :json)
end
