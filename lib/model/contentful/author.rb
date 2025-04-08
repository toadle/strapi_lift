require "active_model"

module Contentful
  class Author
    include StrapiDocumentConnected
    include ActiveModel::Model

    attr_accessor :name

    api_path "/api/authors"

    def title
      name
    end

    def self.contentful_content_type_id
      "3zb7KwmSIESGK2E4iw8ogG"
    end
  end
end
