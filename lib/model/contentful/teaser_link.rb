require_relative 'entry_link'

module Contentful
  class TeaserLink < EntryLink
    attr_accessor :id

    def representer_class
      Contentful::TeaserRepresenter
    end

    def target_class
      Contentful::Teaser
    end
  end
end
