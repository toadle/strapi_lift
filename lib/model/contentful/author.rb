require "active_model"

module Contentful
  class Author
    include StrapiDocumentConnected
    include ActiveModel::Model

    attr_accessor :name

    api_path "/api/authors"

    contentful_content_type "3zb7KwmSIESGK2E4iw8ogG"

    def title
      name
    end
  end
end
