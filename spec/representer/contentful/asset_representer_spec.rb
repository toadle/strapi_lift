require "spec_helper"

RSpec.describe  Contentful::AssetRepresenter do
  let(:asset_data) { JSON.parse(File.read("spec/fixtures/asset_data.json")).deep_transform_keys { |key| key.to_s.underscore } }
  let(:asset) { Contentful::Asset.new }
  let(:representer) { Contentful::AssetRepresenter.new(asset) }

  it "correctly populates fields" do
    asset = Contentful::Asset.new
    Contentful::AssetRepresenter.new(asset).from_hash(asset_data)

    expect(asset.title).to eq("Braut Fascinator il 570xN.410788632 mrki")
    expect(asset.description).to eq("Es ist ein Bild eines Braut-Fascinators, das in einem Online-Shop verkauft wird.")
    expect(asset.file_name).to eq("Braut_Fascinator_il_570xN.410788632_mrki.jpg")
    expect(asset.space_id).to eq("01e3d4iatuxi")
    expect(asset.contenful_id).to eq("7wqPYZhKCc8sEYSK0UYUMW")
    expect(asset.url).to eq("//images.ctfassets.net/01e3d4iatuxi/7wqPYZhKCc8sEYSK0UYUMW/60cd5c83cbe39654e0f849825f484cba/Braut_Fascinator_il_570xN.410788632_mrki.jpg")
  end
end