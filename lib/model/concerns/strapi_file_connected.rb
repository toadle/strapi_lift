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
    self.strapi_file_id = upload_response.dig("id")
    self.strapi_file_url = upload_response.dig("url")

    if self.strapi_file_id
      metadata = {
        caption: title,
        alternativeText: description
      }
      strapi_connection.update_file_info(self.strapi_file_id, metadata)
      puts "Asset #{title} uploaded successfully."
    else
      puts "Failed to upload asset #{title}."
    end
  rescue StandardError => e
    puts "Error uploading asset #{title}: #{e.message}"
  end

  def present_in_strapi?
    ensure_strapi_methods!
    strapi_file_info = strapi_connection.find_file_by_name(file_name)
    return false unless strapi_file_info.present?

    self.strapi_file_id = strapi_file_info.dig("id")
    self.strapi_file_url = strapi_file_info.dig("url")
    puts "Asset #{title} already exists in Strapi with ID #{self.strapi_file_id}."
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