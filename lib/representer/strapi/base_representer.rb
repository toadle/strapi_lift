module Strapi
  class BaseRepresenter < Representable::Decorator
    include Representable::JSON

    property :contentful_id
  end
end