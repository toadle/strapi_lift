module Strapi
  class ArticleRepresenter < Representable::Decorator
    include Representable::JSON

    property :title
    property :slug
    property :content
    property :sponsored_article 
    property :affiliate_notice_hidden 
    property :seo_text 
    property :meta_keywords
    property :meta_description
    property :meta_robots
    property :display_toc
    property :vg_wort_pixel_url
    property :sources
    property :contentful_id
  end
end