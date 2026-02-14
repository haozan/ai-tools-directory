class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.integer :tools_count, default: 0

      t.index :name, unique: true
      t.index :slug, unique: true

      t.timestamps
    end
  end
end
