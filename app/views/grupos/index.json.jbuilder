json.array!(@grupos) do |grupo|
  json.extract! grupo, :id, :nGrupo, :idGrupo, :idBanco, :idAlmacen
  json.url grupo_url(grupo, format: :json)
end
