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
      article.category_link = Contentful::CategoryLink.new
      article.category_link.id = "abcdef"
    end

    xit "return the right data" do
      expect(article.connections_data).to eq(
        {
          "category" => {
            "connect" => ["123456"]
          }
        }
      )
    end

    xit "raises and error when categories can not be found" do
      article.category_link.id = "non_existent_id"

      expect {
        article.connections_data
      }.to raise_error(StandardError, "Category with ID non_existent_id not found to establish connection.")
    end
  end
end