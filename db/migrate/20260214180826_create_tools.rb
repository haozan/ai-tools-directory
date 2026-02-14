class CreateTools < ActiveRecord::Migration[7.2]
  def change
    create_table :tools do |t|
      t.string :name
      t.string :website_url
      t.string :short_description, default: ""
      t.text :long_description
      t.string :logo_url
      t.string :pricing_type, default: "Freemium"
      t.string :slug
      t.integer :view_count, default: 0

      t.index :name
      t.index :pricing_type
      t.index :slug, unique: true

      t.timestamps
    end
  end
end
