module Contentful
  class AssetLink
    attr_accessor :id

    def resolve_link
      asset_data = $assets_data.select { |asset| asset.dig("sys", "id") == id }
      asset = Asset.new
      AssetRepresenter.new(asset).from_hash(asset_data.first)
      asset
    end
  end
end
