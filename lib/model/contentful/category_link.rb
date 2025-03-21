require_relative 'link'

module Contentful
  class CategoryLink < Link
    attr_accessor :id

    def representer_class
      Contentful::CategoryRepresenter
    end

    def target_class
      Contentful::Category
    end
  end
end
