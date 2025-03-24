require 'uri'

module Contentful
  class Asset
    include StrapiFileConnected

    attr_accessor :title, :description, :space_id, :contentful_id, :url, :strapi_file_id

    def save!
      save_to_strapi! unless present_in_strapi?
    end

    def file_name
      File.basename(URI.parse(url).path)
    end
  end
end
