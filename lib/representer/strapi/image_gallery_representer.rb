require_relative 'base_representer'

module Strapi
  class ImageGalleryRepresenter < BaseRepresenter
    property :title
    property :service_provider
    property :description
  end
end