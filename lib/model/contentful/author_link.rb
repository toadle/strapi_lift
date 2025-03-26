require_relative 'entry_link'

module Contentful
  class AuthorLink < EntryLink
    attr_accessor :id

    def representer_class
      Contentful::AuthorRepresenter
    end

    def target_class
      Contentful::Author
    end
  end
end
