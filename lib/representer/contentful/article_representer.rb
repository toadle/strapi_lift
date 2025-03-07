require_relative 'link_representer'

module Contentful
  class ArticleRepresenter < Representable::Decorator
    include Representable::JSON

    nested :fields do
      %w(
          title 
          slug 
          content 
          sponsored_article 
          affiliate_notice_hidden 
          seo_text 
          meta_keywords 
          meta_description 
          meta_robots
          display_toc
          vg_wort_pixel_url
          sources
        ).each do |property_name|
        nested property_name do
          property property_name, as: :de_de
        end
      end

      property :category, decorator: Contentful::LinkRepresenter, class: Contentful::CategoryLink
    end

    nested :sys do
      property :contentful_id, as: :id
    end
  end
end