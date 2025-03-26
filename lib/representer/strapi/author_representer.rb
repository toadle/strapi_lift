module Strapi
  class AuthorRepresenter < Representable::Decorator
    include Representable::JSON

    property :name
  end
end