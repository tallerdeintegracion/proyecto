class CreateProductions < ActiveRecord::Migration
  def change
    create_table :productions do |t|
      t.string :sku
      t.integer :cantidad
      t.datetime :disponible

      t.timestamps null: false
    end
  end
end
