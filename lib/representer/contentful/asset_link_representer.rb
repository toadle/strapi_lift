module Contentful
  class AssetLinkRepresenter < Representable::Decorator
    include Representable::JSON

    nested :sys do
      property :id
    end
  end
end