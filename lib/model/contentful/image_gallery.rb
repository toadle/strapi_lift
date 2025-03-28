require "active_model"

module Contentful
  class ImageGallery
    include StrapiDocumentConnected
    include ActiveModel::Model

    attr_accessor :title
    attr_accessor :description
    attr_accessor :service_provider

    link_assets  source: :image_links, target: :images

    api_path "/api/image-galleries"
  
    def strapi_representer_class
      Strapi::ImageGalleryRepresenter
    end
  end
end
