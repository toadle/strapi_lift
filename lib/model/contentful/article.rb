module Contentful
  class Article
    attr_accessor :contentful_id, :title, :slug, :content, :category, :sponsored_article, :affiliate_notice_hidden, :teaser_image, :seo_text, :meta_keywords, :meta_description, :meta_robots, :date, :display_toc, :vg_wort_pixel_url, :image_gallery, :authors, :sources, :related_articles, :breadcrumbs, :strapi_id

    def connections_data(contentful_categories)
      category_id = category.id
      category_strapi_id = contentful_categories.find { |cat| cat.contentful_id == category_id }&.strapi_id
      raise StandardError, "Category with ID #{category_id} not found to establish connection." unless category_strapi_id

      {
        "category" => {
          "connect" => [category_strapi_id]
        }
      }
    end
  end
end
