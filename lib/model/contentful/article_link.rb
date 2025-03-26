require_relative 'entry_link'

module Contentful
  class ArticleLink < EntryLink
    attr_accessor :id

    def representer_class
      Contentful::ArticleRepresenter
    end

    def target_class
      Contentful::Article
    end
  end
end
