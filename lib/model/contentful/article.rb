module Contentful
  class Article
    include StrapiDocumentConnected
    attr_accessor :title
    attr_accessor :slug
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
    attr_accessor :breadcrumbs
    attr_accessor :teaser_image_id

    rich_text source: :content, target: :content
    link_object source: :category_link, target: :category
    link_object source: :image_gallery_link, target: :image_gallery
    link_asset  source: :teaser_image_link, target: :teaser_image
    link_objects source: :related_article_links, target: :related_articles
    link_objects source: :author_links, target: :authors

    api_path "/api/articles"

    contentful_content_type "5duKiNPsR20mgISegMYmwK"
  end
end
