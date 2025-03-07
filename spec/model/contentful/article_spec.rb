require "spec_helper"

RSpec.describe  Contentful::Article do
  let(:article_data) { JSON.parse(File.read("spec/fixtures/article_data.json")).deep_transform_keys { |key| key.to_s.underscore } }
  let(:article) { Contentful::Article.new }
  let(:representer) { Contentful::ArticleRepresenter.new(article) }

  describe "#connections_data" do
    let(:article) { Contentful::Article.new }
    let(:contentful_categories) do
      [
        Contentful::Category.new(
          contentful_id: "abcdef",
          strapi_id: "123456"
        ),
        Contentful::Category.new(
          contentful_id: "ghijkl",
          strapi_id: "789012"
        )
      ]
    end

    before do
      article.category = Contentful::CategoryLink.new
      article.category.id = "abcdef"
    end

    it "return the right data" do
      expect(article.connections_data(contentful_categories)).to eq(
        {
          "category" => {
            "connect" => ["123456"]
          }
        }
      )
    end

    it "raises and error when categories can not be found" do
      article.category.id = "non_existent_id"

      expect {
        article.connections_data(contentful_categories)
      }.to raise_error(StandardError, "Category with ID non_existent_id not found to establish connection.")
    end
  end
end