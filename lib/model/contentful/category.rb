require "active_model"

module Contentful
  class Category
    include StrapiDocumentConnected
    include ActiveModel::Model

    attr_accessor :title
    attr_accessor :slug
    attr_accessor :image
    attr_accessor :seo_text
    attr_accessor :cat_intro_head
    attr_accessor :cat_introduction
    attr_accessor :seo_text
    attr_accessor :top
    attr_accessor :meta_title
    attr_accessor :meta_keywords
    attr_accessor :meta_description
    attr_accessor :meta_robots

    link_asset  source: :image_link, target: :image
    link_objects source: :subcategory_links, target: :subcategories
    link_objects source: :featured_article_links, target: :featured_articles

    api_path "/api/categories"

    contentful_content_type "2vg0mzjdfm4myqIQyqiW0M"
  end
end
