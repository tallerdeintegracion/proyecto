class CreateInventarios < ActiveRecord::Migration
  def change
    create_table :inventarios do |t|

      t.timestamps null: false
    end
  end
end
