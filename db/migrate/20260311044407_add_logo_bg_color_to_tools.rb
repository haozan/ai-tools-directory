class AddLogoBgColorToTools < ActiveRecord::Migration[7.2]
  def change
    add_column :tools, :logo_bg_color, :string

  end
end
