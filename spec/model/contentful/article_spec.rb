require "spec_helper"

RSpec.describe  Contentful::Article do
  let(:article_data) { JSON.parse(File.read("spec/fixtures/article_data.json")).deep_transform_keys { |key| key.to_s.underscore } }
  let(:article) { Contentful::Article.new }
  let(:representer) { Contentful::ArticleRepresenter.new(article) }

  describe "#content_asset_urls" do
    before do
      representer.from_hash(article_data)
    end

    it "returns the asset url for the article" do
      # expect(article.content_asset_urls.count).to eq(7)
      expect(article.content_asset_urls.first).to eq("//images.ctfassets.net/01e3d4iatuxi/527qCnDNIfQDccTfKViZ5V/2ba797027542f6ad6fff009ff40c06d3/Brautfrisuren_mit_Fascinator_-_myrakim_1.jpg")
    end
  end
end