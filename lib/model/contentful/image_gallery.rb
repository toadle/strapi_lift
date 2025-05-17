require "active_model"

module Contentful
  class ImageGallery
    include StrapiDocumentConnected
    include ActiveModel::Model

    attr_accessor :title
    attr_accessor :description
    attr_accessor :service_provider

    link_assets  source: :image_links, target: :images
    link_objects source: :tag_links, target: :tags, always_resolve: true

    api_path "/api/image-galleries"

    contentful_content_type "6ydFFHu0og4QmSeW6UucIK"
  end
end
