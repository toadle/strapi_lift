require_relative 'base_representer'

module Strapi
  class HomepageRepresenter < BaseRepresenter
    property :title
    property :seo_text
    property :meta_title
    property :meta_description
    property :meta_keywords
  end
end