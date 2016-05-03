class CreateOcs < ActiveRecord::Migration
  def change
    create_table :ocs do |t|
      t.string :oc
      t.string :estados

      t.timestamps null: false
    end
  end
end
