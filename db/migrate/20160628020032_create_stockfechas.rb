class CreateStockfechas < ActiveRecord::Migration
  def change
    create_table :stockfechas do |t|
      t.date :fecha
      t.integer :sku
      t.integer :cantidad

      t.timestamps null: false
    end
  end
end
