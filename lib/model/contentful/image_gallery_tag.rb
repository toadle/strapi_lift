require "active_model"

module Contentful
  class ImageGalleryTag
    include StrapiDocumentConnected
    include ActiveModel::Model

    attr_accessor :title
    attr_accessor :area
    attr_accessor :slug

    api_path "/api/image-gallery-tags"
  
    def strapi_representer_class
      Strapi::ImageGalleryTagRepresenter
    end
  end
end
