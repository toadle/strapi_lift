require_relative 'link_representer'

module Contentful
  class AssetRepresenter < Representable::Decorator
    include Representable::JSON

    nested :sys do
      property :contenful_id, as: :id
      nested :space do
        nested :sys do
          property :space_id, as: :id
        end
      end
    end

    nested :fields do
      %w(
          title 
          description 
        ).each do |property_name|
        nested property_name do
          property property_name, as: :de_de
        end

        nested :file do
          nested :de_de do
            property :url
            property :file_name
          end
        end
      end
    end
  end
end