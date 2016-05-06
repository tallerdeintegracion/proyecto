class CreateOcs < ActiveRecord::Migration
  def change
    create_table :ocs do |t|
      t.string :oc
      t.string :estados
      t.string :canal
      t.string :factura
      t.string :pago
      t.string :sku
      t.integer :cantidad

      t.timestamps null: false
    end
  end
end
