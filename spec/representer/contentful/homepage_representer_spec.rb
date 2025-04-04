require "spec_helper"

RSpec.describe  Contentful::HomepageRepresenter do
  let(:homepage_data) { JSON.parse(File.read("spec/fixtures/homepage_data.json")).deep_transform_keys { |key| key.to_s.underscore } }
  let(:homepage) { Contentful::Homepage.new }
  let(:representer) { Contentful::HomepageRepresenter.new(homepage) }

  it "correctly populates the homepage object" do
    representer.from_hash(homepage_data)

    expect(homepage.title).to eq("Erste Homepage")
    expect(homepage.seo_text).to_not be_blank
    expect(homepage.meta_title).to_not be_blank
    expect(homepage.meta_description).to_not be_blank
    expect(homepage.meta_keywords).to_not be_blank
    expect(homepage.main_menu_links.count).to eq(4)
    expect(homepage.article_links.count).to eq(5)
    expect(homepage.category_links.count).to eq(6)
    expect(homepage.top_teaser_link).to_not be_nil
    expect(homepage.teaser_links.count).to eq(3)
  end
end