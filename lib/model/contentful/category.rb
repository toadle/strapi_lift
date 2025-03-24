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
    attr_accessor :contentful_id
    attr_accessor :strapi_id

    def save!
      save_to_strapi! unless present_in_strapi?
    end

    def strapi_api_path
      "/api/categories"
    end
  
    def strapi_representer_class
      Strapi::CategoryRepresenter
    end
  end
end
