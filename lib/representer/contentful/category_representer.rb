module Contentful
  class CategoryRepresenter < Representable::Decorator
    include Representable::JSON

    nested :fields do
      %w(
          title
          slug
          seo_text
          meta_title
          meta_keywords
          meta_description
          meta_robots
          introduction_headline
          introduction
          vg_wort_pixel_url
        ).each do |property_name|
        nested property_name do
          property property_name, as: :de_de
        end
      end

      nested :image do
        property :image_link, decorator: Contentful::AssetLinkRepresenter, class: Contentful::AssetLink, as: :de_de
      end

    end

    nested :sys do
      property :contentful_id, as: :id
    end
  end
end