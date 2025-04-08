module Contentful
  class CategoryRepresenter < Representable::Decorator
    include Representable::JSON

    nested :fields do
      %w(
          title
          slug
          seo_text
          cat_intro_head
          cat_introduction
          seo_text
          top
          meta_title
          meta_keywords
          meta_description
          meta_robots
        ).each do |property_name|
        nested property_name do
          property property_name, as: :de_de
        end
      end

      nested :image do
        property :image_link, decorator: Contentful::AssetLinkRepresenter, class: Contentful::AssetLink, as: :de_de
      end

      nested :subcategories do
        collection :subcategory_links, decorator: Contentful::EntryLinkRepresenter, class: Contentful::CategoryLink, as: :de_de
      end

      nested :featured_articles do
        collection :featured_article_links, decorator: Contentful::EntryLinkRepresenter, class: Contentful::ArticleLink, as: :de_de
      end

    end

    nested :sys do
      property :contentful_id, as: :id
    end
  end
end