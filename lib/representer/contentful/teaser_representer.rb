require_relative 'entry_link_representer'
require_relative 'asset_link_representer'

module Contentful
  class TeaserRepresenter < Representable::Decorator
    include Representable::JSON

    nested :fields do
      %w(
          title
          subtitle
          text
          cta_text
          url
          display_type
          display_color_type
        ).each do |property_name|
        nested property_name do
          property property_name, as: :de_de
        end
      end

      nested :image do
        property :image_link, decorator: Contentful::AssetLinkRepresenter, class: Contentful::AssetLink, as: :de_de
      end
    end

    nested :sys do
      property :contentful_id, as: :id
    end
  end
end