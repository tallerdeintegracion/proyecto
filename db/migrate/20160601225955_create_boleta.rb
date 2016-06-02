class CreateBoleta < ActiveRecord::Migration
  def change
    create_table :boleta do |t|
      t.string :boleta_id
      t.string :orden_id
      t.string :estado
      t.integer :total

      t.timestamps null: false
    end
  end
end
