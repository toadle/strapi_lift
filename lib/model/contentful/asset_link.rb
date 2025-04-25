require 'semantic_logger'

module Contentful
  class AssetLink
    attr_accessor :id

    def logger
      @logger ||= SemanticLogger[self.class.name]
    end

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
      logger.info("Resolving", id: id)
      asset_data = $assets_data.select { |asset| asset.dig("sys", "id") == id }

      if asset_data.empty?
        logger.error("Could not be resolved", id: id)
        return
      end

      asset = Asset.new
      AssetRepresenter.new(asset).from_hash(asset_data.first)
      asset
    end
  end
end
