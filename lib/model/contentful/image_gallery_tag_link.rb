require_relative 'entry_link'

module Contentful
  class ImageGalleryTagLink < EntryLink
    attr_accessor :id

    def representer_class
      Contentful::ImageGalleryTagRepresenter
    end

    def target_class
      Contentful::ImageGalleryTag
    end
  end
end
