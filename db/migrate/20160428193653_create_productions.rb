class CreateProductions < ActiveRecord::Migration
  def change
    create_table :productions do |t|
      t.string :sku
      t.integer :cantidad
      t.integer :timeStamp

      t.timestamps null: false
    end
  end
end
