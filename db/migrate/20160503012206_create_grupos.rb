class CreateGrupos < ActiveRecord::Migration
  def change
    create_table :grupos do |t|
      t.integer :nGrupo
      t.string :idGrupo
      t.string :idBanco
      t.string :idAlmacen

      t.timestamps null: false
    end
  end
end
