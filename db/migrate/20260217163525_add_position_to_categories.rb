class AddPositionToCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :position, :integer, default: 0
    add_index :categories, :position
  end
end
