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
    def reset_strapi!
      connection = Strapi::Connection.new
      response = connection.get("/api/upload/files")
      files = response.body || []

      files.each do |file|
        connection.delete("/api/upload/files/#{file['id']}")
        $logger.log_progress("ID #{file['id']} deleted successfully.", self.name, :info, file["caption"])
      end
    end
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

    if self.strapi_file_id
      metadata = {
        caption: title,
        alternativeText: description
      }
      strapi_connection.update_file_info(self.strapi_file_id, metadata)
      $logger.log_progress("Uploaded successfully as File ID #{self.strapi_file_id}.", self.class.name, :info, title)
    else
      $logger.log_progress("Failed to upload asset.", self.class.name, :error, title)
    end
  rescue StandardError => e
    $logger.log_progress("Error uploading asset: #{e.message}", self.class.name, :error, title)
  end

  def present_in_strapi?
    ensure_strapi_methods!
    strapi_file_info = strapi_connection.find_file_by_name(file_name)
    return false unless strapi_file_info.present?

    self.strapi_file_id = strapi_file_info.dig("id")
    self.strapi_file_url = strapi_file_info.dig("url")
    $logger.log_progress("Already exists in Strapi with ID #{self.strapi_file_id}.", self.class.name, :info, title)
    return true
  end

  def discover_file_path
    file_path = File.join($assets_folder, URI.parse(url).path)
    raise "File not found: #{file_path}" unless File.exist?(file_path)
    file_path
  end

  def strapi_connection
    @strapi_connection ||= Strapi::Connection.new
  end
end