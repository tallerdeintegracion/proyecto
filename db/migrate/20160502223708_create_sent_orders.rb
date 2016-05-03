class CreateSentOrders < ActiveRecord::Migration
  def change
    create_table :sent_orders do |t|
      t.string :oc
      t.string :sku
      t.integer :cantidad
      t.string :estado

      t.timestamps null: false
    end
  end
end
