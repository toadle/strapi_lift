require_relative 'base_representer'

module Strapi
  class ImageGalleryTagRepresenter < BaseRepresenter
    property :title
    property :area
    property :slug
  end
end