class CreateResources < ActiveRecord::Migration[7.2]
  def change
    create_table :resources do |t|
      t.string :title
      t.text :description
      t.string :url
      t.string :category
      t.string :subscribers_count
      t.string :logo_url
      t.boolean :featured, default: false
      t.integer :view_count, default: 0


      t.timestamps
    end
  end
end
