module Contentful
  class Homepage
    include StrapiDocumentConnected
    attr_accessor :title
    attr_accessor :seo_text
    attr_accessor :meta_title
    attr_accessor :meta_description
    attr_accessor :meta_keywords

    link_objects source: :main_menu_links, target: :main_menu
    link_objects source: :article_links, target: :articles
    link_objects source: :category_links, target: :categories
    link_objects source: :teaser_links, target: :teasers
    link_object source: :top_teaser_link, target: :top_teaser

    api_path "/api/homepage"
    single_content_type!

    def self.contentful_content_type_id
      "42rOugxTn2akMskSggwqKE"
    end
  end
end
