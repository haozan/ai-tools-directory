class Tool < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  # Associations
  has_many :tool_categories, dependent: :destroy
  has_many :categories, through: :tool_categories
  has_one_attached :logo
  
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :website_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :short_description, length: { maximum: 150 }
  
  # Scopes
  scope :popular, -> { order(view_count: :desc) }
  scope :newest, -> { order(created_at: :desc) }
  scope :search_by_name, ->(query) { where('name ILIKE ?', "%#{query}%") if query.present? }
  
  # Callbacks
  after_create :update_categories_count
  after_destroy :update_categories_count
  after_save :auto_extract_og_image, if: :should_extract_og_image?
  
  # Return logo URL (prioritize ActiveStorage, fallback to logo_url field)
  def logo_image_url
    if logo.attached?
      Rails.application.routes.url_helpers.rails_blob_url(logo, only_path: true)
    else
      logo_url.presence
    end
  end
  
  private
  
  def update_categories_count
    categories.each(&:update_tools_count!)
  end
  
  def should_extract_og_image?
    # Auto-extract if: website_url changed AND no logo attached AND no logo_url
    saved_change_to_website_url? && !logo.attached? && logo_url.blank?
  end
  
  def auto_extract_og_image
    og_image_url = OgImageExtractorService.call(website_url)
    return if og_image_url.blank?
    
    # Try to attach the image from URL
    begin
      logo.attach(
        io: URI.open(og_image_url),
        filename: "#{slug || name.parameterize}.jpg",
        content_type: 'image/jpeg'
      )
      Rails.logger.info("Successfully attached OG image for tool: #{name}")
    rescue StandardError => e
      Rails.logger.error("Failed to attach OG image for tool #{name}: #{e.message}")
      # Fallback: save to logo_url field
      update_column(:logo_url, og_image_url)
    end
  end
end
