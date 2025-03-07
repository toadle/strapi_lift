module Contentful
  class LinkRepresenter < Representable::Decorator
    include Representable::JSON

    nested :de_de do
      nested :sys do
        property :id
      end
    end
  end
end