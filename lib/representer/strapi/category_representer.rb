module Strapi
  class CategoryRepresenter < Representable::Decorator
    include Representable::JSON

    property :title
    property :slug
    property :contentful_id
    property :seo_text
    property :meta_title
    property :meta_keywords
    property :meta_description
    property :meta_robots
    property :introduction_headline
    property :introduction
    property :vg_wort_pixel_url
  end
end