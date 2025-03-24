require "spec_helper"

RSpec.describe  Contentful::ArticleRepresenter do
  let(:article_data) { JSON.parse(File.read("spec/fixtures/article_data.json")).deep_transform_keys { |key| key.to_s.underscore } }
  let(:article) { Contentful::Article.new }
  let(:representer) { Contentful::ArticleRepresenter.new(article) }

  it "correctly populates the category link" do
    article = Contentful::Article.new
    Contentful::ArticleRepresenter.new(article).from_hash(article_data)

    expect(article.category_link).to be_a(Contentful::CategoryLink)
    expect(article.category_link.id).to eq("4QOCXj1qeAO0UeCmykS6uc")
  end

  it "correctly populates the teaser image link" do
    article = Contentful::Article.new
    Contentful::ArticleRepresenter.new(article).from_hash(article_data)

    expect(article.teaser_image_link).to be_a(Contentful::AssetLink)
    expect(article.teaser_image_link.id).to eq("4CIETmeecok2S6AMOQEaGG")
  end
end