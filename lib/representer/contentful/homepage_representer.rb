require_relative 'entry_link_representer'
require_relative 'asset_link_representer'

module Contentful
  class HomepageRepresenter < Representable::Decorator
    include Representable::JSON

    nested :fields do
      %w(
          title
          seo_text
          meta_title
          meta_description
          meta_keywords
        ).each do |property_name|
        nested property_name do
          property property_name, as: :de_de
        end
      end

      nested :top_teaser do
        property :top_teaser_link, decorator: Contentful::EntryLinkRepresenter, class: Contentful::TeaserLink, as: :de_de
      end
      nested :main_menu do
        collection :main_menu_links, decorator: Contentful::EntryLinkRepresenter, class: Contentful::CategoryLink, as: :de_de
      end
      nested :articles do
        collection :article_links, decorator: Contentful::EntryLinkRepresenter, class: Contentful::ArticleLink, as: :de_de
      end
      nested :categories do
        collection :category_links, decorator: Contentful::EntryLinkRepresenter, class: Contentful::CategoryLink, as: :de_de
      end
      nested :teasers do
        collection :teaser_links, decorator: Contentful::EntryLinkRepresenter, class: Contentful::TeaserLink, as: :de_de
      end
    end

    nested :sys do
      property :contentful_id, as: :id
    end
  end
end