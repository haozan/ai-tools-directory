class ExtractOgImageJob < ApplicationJob
  queue_as :default

  def perform(tool_id)
    tool = Tool.find_by(id: tool_id)
    return unless tool

    og_image_url = OgImageExtractorService.call(tool.website_url)
    return if og_image_url.blank?

    # 清除旧图
    tool.logo.purge if tool.logo.attached?

    begin
      tool.logo.attach(
        io: URI.open(og_image_url),
        filename: "#{tool.slug || tool.name.parameterize}.jpg",
        content_type: 'image/jpeg'
      )
      Rails.logger.info("[ExtractOgImageJob] Success: #{tool.name}")
    rescue StandardError => e
      Rails.logger.error("[ExtractOgImageJob] Failed to attach image for #{tool.name}: #{e.message}")
      tool.update_column(:logo_url, og_image_url)
    end
  end
end
