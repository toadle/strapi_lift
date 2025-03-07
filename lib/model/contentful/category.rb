require "active_model"

module Contentful
  class Category
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
  end
end
