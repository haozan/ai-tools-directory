class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  # Associations
  has_many :tool_categories, dependent: :destroy
  has_many :tools, through: :tool_categories
  
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, uniqueness: true
  
  # Scopes
  scope :with_tools, -> { where('tools_count > 0') }
  scope :popular, -> { order(tools_count: :desc) }
  
  def update_tools_count!
    update(tools_count: tools.count)
  end
end
