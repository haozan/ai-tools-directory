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
  scope :featured, -> { where(featured: true).order(created_at: :desc) }
  scope :search_by_name, ->(query) { where('name ILIKE ?', "%#{query}%") if query.present? }
  scope :by_pricing, ->(pricing) { where(pricing: pricing) if pricing.present? }
  
  # Callbacks
  after_create :update_categories_count
  before_destroy :cache_category_ids   # 在关联被 destroy 前先缓存
  after_destroy :update_cached_categories_count
  after_save :auto_extract_og_image, if: :should_extract_og_image?
  
  # 异步重新抓取 OG 图（enqueue 后台 job，不阻塞请求）
  def extract_og_image!
    update_column(:logo_url, nil) if logo_url.present?
    ExtractOgImageJob.perform_later(id)
    true
  end

  # 判断是否为图标类 URL（LobeHub SVG 等正方形图标，不应裁剪）
  def logo_is_icon?
    return false unless logo_url.present?
    logo_url.include?('lobehub/icons') ||
      logo_url.end_with?('.svg') ||
      logo_url.include?('icon')
  end

  # 白色图标列表（图标本身是白色，需要深色背景才可见）
  WHITE_ICON_KEYWORDS = %w[kimi].freeze

  def logo_display_bg
    return '#1a1a2e' if WHITE_ICON_KEYWORDS.any? { |kw| logo_url.to_s.downcase.include?(kw) }
    '#ffffff'
  end

  # Return logo URL (prioritize logo_url field, fallback to ActiveStorage)
  # This ensures static assets in /public/images/logos are used in production
  def logo_image_url
    if logo_url.present?
      logo_url
    elsif logo.attached?
      # 生产环境用完整 URL（七牛 CDN），开发环境用相对路径
      if Rails.env.production?
        Rails.application.routes.url_helpers.rails_blob_url(logo)
      else
        Rails.application.routes.url_helpers.rails_blob_url(logo, only_path: true)
      end
    end
  end
  
  private

  def cache_category_ids
    @cached_category_ids = categories.pluck(:id)
  end

  def update_categories_count
    categories.each(&:update_tools_count!)
  end

  def update_cached_categories_count
    Category.where(id: @cached_category_ids).each(&:update_tools_count!)
  end
  
  def should_extract_og_image?
    # Auto-extract if: website_url changed AND no logo attached AND no logo_url
    saved_change_to_website_url? && !logo.attached? && logo_url.blank?
  end
  
  def auto_extract_og_image
    # 异步 enqueue，不在 web 请求中直接发 HTTP 请求
    ExtractOgImageJob.perform_later(id)
    Rails.logger.info("[Tool] Enqueued ExtractOgImageJob for: #{name}")
  end
end
