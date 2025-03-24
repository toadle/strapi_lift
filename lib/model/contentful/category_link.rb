require_relative 'entry_link'

module Contentful
  class CategoryLink < EntryLink
    attr_accessor :id

    def representer_class
      Contentful::CategoryRepresenter
    end

    def target_class
      Contentful::Category
    end
  end
end
