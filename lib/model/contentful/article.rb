module Contentful
  class Article
    include StrapiDocumentConnected
    attr_accessor :contentful_id
    attr_accessor :title
    attr_accessor :slug
    attr_accessor :content
    attr_accessor :sponsored_article
    attr_accessor :affiliate_notice_hidden
    
    attr_accessor :seo_text
    attr_accessor :meta_keywords
    attr_accessor :meta_description
    attr_accessor :meta_robots
    attr_accessor :date
    attr_accessor :display_toc
    attr_accessor :vg_wort_pixel_url
    attr_accessor :image_gallery
    attr_accessor :authors
    attr_accessor :sources
    attr_accessor :related_articles
    attr_accessor :breadcrumbs
    attr_accessor :strapi_id
    attr_accessor :teaser_image_id

    link_object source: :category_link, target: :category
    link_asset  source: :teaser_image_link, target: :teaser_image
  
    def category_link
      @category_link
    end
  
    def teaser_image_link
      @teaser_image_link
    end

    def strapi_api_path
      "/api/articles"
    end
  
    def strapi_representer_class
      Strapi::ArticleRepresenter
    end
  end
end
