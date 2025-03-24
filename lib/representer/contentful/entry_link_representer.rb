module Contentful
  class EntryLinkRepresenter < Representable::Decorator
    include Representable::JSON

    nested :de_de do
      nested :sys do
        property :id
      end
    end
  end
end