require_relative 'entry_link_representer'
require_relative 'asset_link_representer'

module Contentful
  class ImageGalleryRepresenter < Representable::Decorator
    include Representable::JSON

    nested :fields do
      %w(
          title
          description
          service_provider
        ).each do |property_name|
        nested property_name do
          property property_name, as: :de_de
        end

        nested :images do
          collection :image_links, decorator: Contentful::AssetLinkRepresenter, class: Contentful::AssetLink, as: :de_de
        end

        nested :tags do
          collection :tag_links, decorator: Contentful::EntryLinkRepresenter, class: Contentful::ImageGalleryTagLink, as: :de_de
        end
      end
    end

    nested :sys do
      property :contentful_id, as: :id
    end
  end
end
