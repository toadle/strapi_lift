require_relative 'entry_link_representer'
require_relative 'asset_link_representer'

module Contentful
  class ImageGalleryTagRepresenter < Representable::Decorator
    include Representable::JSON

    nested :fields do
      %w(
          title
          area
          slug
        ).each do |property_name|
        nested property_name do
          property property_name, as: :de_de
        end
      end
    end

    nested :sys do
      property :contentful_id, as: :id
    end
  end
end