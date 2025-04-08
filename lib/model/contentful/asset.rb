require 'uri'

module Contentful
  class Asset
    include StrapiFileConnected

    attr_accessor :title, :description, :space_id, :contentful_id, :url, :strapi_file_id, :strapi_file_url

    def save!
      save_to_strapi! unless present_in_strapi?
    end

    def file_name
      encoded_url = URI::DEFAULT_PARSER.escape(url)
      File.basename(URI.parse(encoded_url).path)
    end
  end
end
