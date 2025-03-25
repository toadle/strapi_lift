module Contentful
  class AssetLink
    attr_accessor :id

    def self.from_url(url)
      uri = URI.parse(url.start_with?("//") ? "https:#{url}" : url)
    
      segments = uri.path.split("/")
      if segments.length >= 3 && segments[2].match?(/\A[a-zA-Z0-9]+\z/)
        new.tap { |asset_link| asset_link.id = segments[2] }
      else
        raise ArgumentError, "Invalid Contentful asset URL format"
      end
    end

    def resolve_link
      asset_data = $assets_data.select { |asset| asset.dig("sys", "id") == id }
      asset = Asset.new
      AssetRepresenter.new(asset).from_hash(asset_data.first)
      asset
    end
  end
end
