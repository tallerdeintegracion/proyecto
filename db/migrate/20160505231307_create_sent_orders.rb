class CreateSentOrders < ActiveRecord::Migration
  def change
   # drop_table :sent_orders
    create_table :sent_orders do |t|
      t.string :oc
      t.string :sku
      t.integer :cantidad
      t.string :estado
      t.datetime :fechaEntrega

      t.timestamps null: false
    end
  end
end
