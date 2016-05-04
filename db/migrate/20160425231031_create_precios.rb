class CreatePrecios < ActiveRecord::Migration
  def change
    create_table :precios do |t|
      t.string :sku
      t.string :descripcion
      t.integer :precioUnitario

      t.timestamps null: false
    end
  end
end
