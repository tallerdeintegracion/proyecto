class CreateSocialMedia < ActiveRecord::Migration
  def change
    create_table :social_media do |t|

      t.timestamps null: false
    end
  end
end
