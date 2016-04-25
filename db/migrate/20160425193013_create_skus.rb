class CreateSkus < ActiveRecord::Migration
  def change
    create_table :skus do |t|
      t.string :sku
      t.string :descripcion
      t.string :tipo
      t.string :grupoProyecto
      t.string :unidades
      t.integer :costoUnitario
      t.integer :loteProduccion
      t.float :tiempoProduccion

      t.timestamps null: false
    end
  end
end
