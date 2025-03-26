module Contentful
  class EntryLinkRepresenter < Representable::Decorator
    include Representable::JSON

    nested :sys do
      property :id
    end
  end
end