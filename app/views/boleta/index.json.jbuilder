json.array!(@boleta) do |boletum|
  json.extract! boletum, :id, :boleta_id, :orden_id, :estado
  json.url boletum_url(boletum, format: :json)
end
