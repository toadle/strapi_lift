require_relative 'base_representer'

module Strapi
  class CategoryRepresenter < BaseRepresenter
    property :title
    property :slug
    property :seo_text
    property :cat_intro_head
    property :cat_introduction
    property :seo_text
    property :top
    property :meta_title
    property :meta_keywords
    property :meta_description
    property :meta_robots
  end
end