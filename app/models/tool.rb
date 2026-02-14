class Tool < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  # Associations
  has_many :tool_categories, dependent: :destroy
  has_many :categories, through: :tool_categories
  
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :website_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :short_description, length: { maximum: 150 }
  validates :pricing_type, inclusion: { in: %w[Free Freemium Paid] }
  
  # Scopes
  scope :by_pricing, ->(type) { where(pricing_type: type) if type.present? }
  scope :popular, -> { order(view_count: :desc) }
  scope :newest, -> { order(created_at: :desc) }
  scope :search_by_name, ->(query) { where('name ILIKE ?', "%#{query}%") if query.present? }
  
  # Callbacks
  after_create :update_categories_count
  after_destroy :update_categories_count
  
  private
  
  def update_categories_count
    categories.each(&:update_tools_count!)
  end
end
