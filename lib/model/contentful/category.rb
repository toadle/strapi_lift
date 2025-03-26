require "active_model"

module Contentful
  class Category
    include StrapiDocumentConnected
    include ActiveModel::Model

    attr_accessor :title
    attr_accessor :slug
    attr_accessor :image
    attr_accessor :seo_text
    attr_accessor :meta_title
    attr_accessor :meta_keywords
    attr_accessor :meta_description
    attr_accessor :meta_robots
    attr_accessor :introduction_headline
    attr_accessor :introduction
    attr_accessor :vg_wort_pixel_url

    link_asset  source: :image_link, target: :image

    api_path "/api/categories"
  
    def strapi_representer_class
      Strapi::CategoryRepresenter
    end
  end
end
