require "active_model"

module Contentful
  class ImageGalleryTag
    include StrapiDocumentConnected
    include ActiveModel::Model

    attr_accessor :title
    attr_accessor :area
    attr_accessor :slug

    api_path "/api/image-gallery-tags"

    def self.contentful_content_type_id
      "3ks1SSosbmACcEIOsCGsAI"
    end
  end
end
