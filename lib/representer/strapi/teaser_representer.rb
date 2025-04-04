require_relative 'base_representer'

module Strapi
  class TeaserRepresenter < BaseRepresenter
    property :title
    property :subtitle
    property :text
    property :cta_text
    property :url
    property :display_type
    property :display_color_type
  end
end