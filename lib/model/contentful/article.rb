module Contentful
  class Article
    include StrapiDocumentConnected
    attr_accessor :contentful_id
    attr_accessor :title
    attr_accessor :slug
    attr_accessor :content
    attr_accessor :category_link
    attr_accessor :sponsored_article
    attr_accessor :affiliate_notice_hidden
    attr_accessor :teaser_image_link
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

    def save!
      @category = category_link.resolve_link
      @category.save!

      teaser_image = teaser_image_link.resolve_link
      
      if teaser_image
        teaser_image.save!
        @teaser_image_id = teaser_image.strapi_file_id
      end

      save_to_strapi! unless present_in_strapi?
      update_connections!
    end

    def connections_data
      {
        "category" => {
          "connect" => [@category.strapi_id],
        },
        "teaserImage" => @teaser_image_id
      }
    end

    def strapi_api_path
      "/api/articles"
    end
  
    def strapi_representer_class
      Strapi::ArticleRepresenter
    end
  end
end
