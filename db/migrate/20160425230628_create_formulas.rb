class CreateFormulas < ActiveRecord::Migration
  def change
    create_table :formulas do |t|
      t.string :sku
      t.string :descripcion
      t.integer :lote
      t.integer :unidad
      t.string :skuIngerdiente
      t.string :ingrediente
      t.integer :requerimiento
      t.integer :unidadIngrediente
      t.integer :precioIngrediente

      t.timestamps null: false
    end
  end
end
