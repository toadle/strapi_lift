module Contentful
  class Teaser
    include StrapiDocumentConnected
    attr_accessor :title
    attr_accessor :subtitle
    attr_accessor :text
    attr_accessor :cta_text
    attr_accessor :url
    attr_accessor :display_type
    attr_accessor :display_color_type

    api_path "/api/teasers"

    link_asset source: :image_link, target: :image
  
    def strapi_representer_class
      Strapi::TeaserRepresenter
    end
  end
end
