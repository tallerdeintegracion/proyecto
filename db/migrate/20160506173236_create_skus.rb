class CreateSkus < ActiveRecord::Migration
  def change
    create_table :skus do |t|
      t.string :sku
      t.string :descripcion
      t.string :tipo
      t.string :grupoProyecto
      t.integer :costoUnitario
      t.integer :loteProduccion
      t.float :tiempoProduccion
      t.integer :reservado

      t.timestamps null: false
    end
  end
end
