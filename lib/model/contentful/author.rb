require "active_model"

module Contentful
  class Author
    include StrapiDocumentConnected
    include ActiveModel::Model

    attr_accessor :name

    api_path "/api/authors"
  
    def strapi_representer_class
      Strapi::AuthorRepresenter
    end

    def title
      name
    end
  end
end
