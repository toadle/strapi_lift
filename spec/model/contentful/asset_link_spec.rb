require "spec_helper"

RSpec.describe Contentful::AssetLink do
  let(:url) { "//images.ctfassets.net/01e3d4iatuxi/u6T0FS3YUw9FYyBHj4Ce4/e7e870bb524c730d374a83d9bb3d2e0f/Brautfrisuren_mit_Fascinator_-_Haarspange_-_StellaKobenhavnShop.jpg" }

  describe "#from_url" do
    it "sets the correct ID" do
      asset_link = Contentful::AssetLink.from_url(url)

      expect(asset_link.id).to eq("u6T0FS3YUw9FYyBHj4Ce4")
    end
  end
end