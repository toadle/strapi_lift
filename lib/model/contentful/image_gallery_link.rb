require_relative 'entry_link'

module Contentful
  class ImageGalleryLink < EntryLink
    attr_accessor :id

    def representer_class
      Contentful::ImageGalleryRepresenter
    end

    def target_class
      Contentful::ImageGallery
    end
  end
end
