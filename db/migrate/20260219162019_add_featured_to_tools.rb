class AddFeaturedToTools < ActiveRecord::Migration[7.2]
  def change
    add_column :tools, :featured, :boolean, default: false, null: false
  end
end
