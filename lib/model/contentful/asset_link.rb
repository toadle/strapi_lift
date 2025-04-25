module Contentful
  class AssetLink
    attr_accessor :id

    def self.from_url(url)
      encoded_url = URI::DEFAULT_PARSER.escape(url.start_with?("//") ? "https:#{url}" : url)
      uri = URI.parse(encoded_url)

      segments = uri.path.split("/")
      if segments.length >= 3 && segments[2].match?(/\A[a-zA-Z0-9]+\z/)
        new.tap { |asset_link| asset_link.id = segments[2] }
      else
        raise ArgumentError, "Invalid Contentful asset URL format"
      end
    end

    def resolve_link
      asset_data = $assets_data.select { |asset| asset.dig("sys", "id") == id }

      if asset_data.empty?
        $logger.log_progress("AssetLink could not be resolved", self.class.name, :error, id)
        return
      end

      asset = Asset.new
      AssetRepresenter.new(asset).from_hash(asset_data.first)
      $logger.log_progress("Processing '#{asset.title}' through link.", self.class.name, :info, id)
      asset
    end
  end
end
