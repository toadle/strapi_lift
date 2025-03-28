require_relative 'entry_link_representer'
require_relative 'asset_link_representer'

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

      nested :image_gallery do
        property :image_gallery_link, decorator: Contentful::EntryLinkRepresenter, class: Contentful::ImageGalleryLink, as: :de_de
      end
      nested :category do 
        property :category_link, decorator: Contentful::EntryLinkRepresenter, class: Contentful::CategoryLink, as: :de_de
      end
      nested :teaser_image do
        property :teaser_image_link, decorator: Contentful::AssetLinkRepresenter, class: Contentful::AssetLink, as: :de_de
      end
      nested :related_articles do
        collection :related_article_links, decorator: Contentful::EntryLinkRepresenter, class: Contentful::ArticleLink, as: :de_de
      end
      nested :authors do
        collection :author_links, decorator: Contentful::EntryLinkRepresenter, class: Contentful::AuthorLink, as: :de_de
      end
    end

    nested :sys do
      property :contentful_id, as: :id
    end
  end
end