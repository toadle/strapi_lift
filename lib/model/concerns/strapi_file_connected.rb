require 'semantic_logger'
require 'parallel'

module StrapiFileConnected
  extend ActiveSupport::Concern

  REQUIRED_INSTANCE_METHODS = %i[
    contentful_id
    strapi_file_id
    url
    title
    description
    file_name
  ]

  class_methods do
    def logger
      @logger ||= SemanticLogger[self.name]
    end

    def reset_strapi!
      connection = Strapi::Connection.new
      response = connection.get("/api/upload/files")
      files = response.body || []

      Parallel.each(files, in_threads: 10) do |file|
        connection.delete("/api/upload/files/#{file['id']}")
        logger.info("Deleted successfully", id: file['id'], caption: file['caption'])
      end
    end
  end

  def logger
    self.class.logger
  end

  def ensure_strapi_methods!
    missing = REQUIRED_INSTANCE_METHODS.reject { |m| respond_to?(m) }
    unless missing.empty?
      raise NotImplementedError, "Missing required method(s) for StrapiFileConnected: #{missing.join(', ')}"
    end
  end

  def save_to_strapi!
    ensure_strapi_methods!
    file_path = discover_file_path
    upload_response = strapi_connection.upload_file(file_path)

    self.strapi_file_id = upload_response.first.dig("id")
    self.strapi_file_url = upload_response.first.dig("url")

    if title.present? && title.length > 255
      logger.warn("Title too long, truncating", title: title)
    end

    if description.present? && description.length > 255
      logger.warn("Description too long, truncating", description: description)
    end

    if self.strapi_file_id
      metadata = {
        caption: title&.truncate(255),
        alternativeText: description&.truncate(255),
      }
      strapi_connection.update_file_info(self.strapi_file_id, metadata)
      logger.info("Uploaded successfully", file_id: self.strapi_file_id, title: title)
    else
      logger.error("Failed to upload asset", title: title)
    end
  rescue StandardError => e
    logger.error("Error uploading asset", message: e.message, title: title)
  end

  def present_in_strapi?
    ensure_strapi_methods!
    strapi_file_info = strapi_connection.find_file_by_name(file_name)
    return false unless strapi_file_info.present?

    self.strapi_file_id = strapi_file_info.dig("id")
    self.strapi_file_url = strapi_file_info.dig("url")
    logger.info("Found existing file", strapi_file_id: self.strapi_file_id, title: title)
    return true
  end

  def discover_file_path
    file_path = File.join($assets_folder, URI.parse(url).path)
    
    if File.exist?(file_path)
      if File.size(file_path) > 0
        return file_path
      else
        logger.warn("File is empty", file_path: file_path)
      end
    end

    folder = File.dirname(file_path)
    fallback_file = Dir.glob(File.join(folder, '*')).find { |f| File.size(f) > 0 }

    if fallback_file
      logger.warn("Using fallback file", expected: file_path, used: fallback_file)
      return fallback_file
    else
      raise "File not found, empty, and no fallback available in folder: #{folder}"
    end
  end

  def strapi_connection
    @strapi_connection ||= Strapi::Connection.new
  end
end
