require_relative "./strapi/connection"

class EntriesImporter
  def initialize(contentful_content_type, strapi_content_type)
    @contentful_content_type = contentful_content_type
    @strapi_content_type = strapi_content_type
  end

  def run(entries_data)
    entries_data.fetch("entries")[0..10].each do |entry|
      puts entry.dig("fields", "title", "de-de")
    end
  end

  private 

  def strapi_connection
    @strapi_connection ||= Strapi::Connection.new
  end

end