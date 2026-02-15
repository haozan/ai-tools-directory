# Service to extract Open Graph image from website URL
class OgImageExtractorService < ApplicationService
  require 'open-uri'
  require 'nokogiri'
  require 'net/http'

  def initialize(url)
    @url = url
  end

  def call
    extract_og_image
  end

  private

  def extract_og_image
    return nil if @url.blank?

    uri = URI.parse(normalize_url(@url))
    return nil unless valid_uri?(uri)

    html = fetch_html(uri)
    return nil if html.blank?

    parse_og_image(html, uri)
  rescue StandardError => e
    Rails.logger.error("OgImageExtractorService error for #{@url}: #{e.message}")
    nil
  end

  def normalize_url(url)
    url = url.strip
    url = "https://#{url}" unless url.match?(/\Ahttps?:\/\//)
    url
  end

  def valid_uri?(uri)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  end

  def fetch_html(uri)
    response = Net::HTTP.get_response(uri)
    
    # Handle redirects
    if response.is_a?(Net::HTTPRedirection)
      redirect_uri = URI.parse(response['location'])
      redirect_uri = uri + redirect_uri if redirect_uri.relative?
      response = Net::HTTP.get_response(redirect_uri)
    end

    return nil unless response.is_a?(Net::HTTPSuccess)
    
    response.body
  rescue StandardError => e
    Rails.logger.error("Failed to fetch HTML from #{uri}: #{e.message}")
    nil
  end

  def parse_og_image(html, base_uri)
    doc = Nokogiri::HTML(html)
    
    # Try Open Graph image first
    og_image = doc.at_css('meta[property="og:image"]')&.[]('content') ||
               doc.at_css('meta[property="og:image:url"]')&.[]('content')
    
    # Fallback to Twitter Card image
    og_image ||= doc.at_css('meta[name="twitter:image"]')&.[]('content') ||
                 doc.at_css('meta[property="twitter:image"]')&.[]('content')
    
    # Fallback to favicon
    og_image ||= doc.at_css('link[rel="icon"]')&.[]('href') ||
                 doc.at_css('link[rel="shortcut icon"]')&.[]('href') ||
                 doc.at_css('link[rel="apple-touch-icon"]')&.[]('href')
    
    return nil if og_image.blank?
    
    # Convert relative URL to absolute URL
    absolute_url(og_image, base_uri)
  end

  def absolute_url(url, base_uri)
    return url if url.match?(/\Ahttps?:\/\//)
    
    uri = URI.parse(url)
    if uri.relative?
      base_uri.merge(uri).to_s
    else
      url
    end
  rescue StandardError => e
    Rails.logger.error("Failed to parse image URL #{url}: #{e.message}")
    url
  end
end
