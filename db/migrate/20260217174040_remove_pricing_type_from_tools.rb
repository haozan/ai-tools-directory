class RemovePricingTypeFromTools < ActiveRecord::Migration[7.2]
  def change
    remove_column :tools, :pricing_type, :string
  end
end
