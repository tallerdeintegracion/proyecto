class CreateSistemas < ActiveRecord::Migration
  def change
    create_table :sistemas do |t|

      t.timestamps null: false
    end
  end
end
