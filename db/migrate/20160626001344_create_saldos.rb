class CreateSaldos < ActiveRecord::Migration
  def change
    create_table :saldos do |t|
      t.date :fecha
      t.integer :monto

      t.timestamps null: false
    end
  end
end
