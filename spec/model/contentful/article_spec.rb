require "spec_helper"

RSpec.describe Contentful::Article do
  let(:article_data) { JSON.parse(File.read("spec/fixtures/article_data.json")).deep_transform_keys { |key| key.to_s.underscore } }
  let(:article) { Contentful::Article.new }
  let(:representer) { Contentful::ArticleRepresenter.new(article) }

  describe "#content_asset_urls" do
    before do
      representer.from_hash(article_data)
    end

    it "returns the asset url for the article" do
      expect(article.content_asset_urls.count).to eq(7)
      expect(article.content_asset_urls.first).to eq("//images.ctfassets.net/01e3d4iatuxi/527qCnDNIfQDccTfKViZ5V/2ba797027542f6ad6fff009ff40c06d3/Brautfrisuren_mit_Fascinator_-_myrakim_1.jpg")
    end

    describe "with problematic content" do
      let(:article_data) { JSON.parse(File.read("spec/fixtures/problematic_images_in_rich_text.json")).deep_transform_keys { |key| key.to_s.underscore } }
      before do
        representer.from_hash(article_data)
      end

      it "returns the asset url for the article" do
        expect(article.content_asset_urls.count).to eq(6)
      end
    end
  end

  describe "#resolve_rich_text_fields" do
    let(:article_data) { JSON.parse(File.read("spec/fixtures/problematic_images_in_rich_text.json")).deep_transform_keys { |key| key.to_s.underscore } }
    let(:asset) { instance_double("Contentful::Asset", strapi_file_url: "https://strapi.example.com/uploads/asset.jpg") }
    let(:asset_link) { instance_double("Contentful::AssetLink", resolve_link: asset) }

    before do
      allow(Contentful::AssetLink).to receive(:from_url).and_return(asset_link)
      allow(asset).to receive(:save!)
      representer.from_hash(article_data)
    end

    it "replaces asset URLs in rich text fields with Strapi file URLs" do
      article.send(:resolve_rich_text_fields)

      expect(article.content).to include("https://strapi.example.com/uploads/asset.jpg")
      expect(article.content).not_to include("//images.ctfassets.net")
      expect(article.content).not_to include("//images.contentful.com")
    end
  end
end