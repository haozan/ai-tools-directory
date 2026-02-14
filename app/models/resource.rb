class Resource < ApplicationRecord
  # Validations
  validates :title, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :category, presence: true, inclusion: { in: %w[video document media] }
  
  # Scopes
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :featured, -> { where(featured: true) }
  scope :popular, -> { order(view_count: :desc) }
  scope :newest, -> { order(created_at: :desc) }
end
