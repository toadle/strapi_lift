require "spec_helper"

RSpec.describe Contentful::Asset do
  let(:asset) { Contentful::Asset.new }
  let(:base_path) { "/base/path" }
  let(:file_path) { "/base/path/01e3d4iatuxi/7wqPYZhKCc8sEYSK0UYUMW/60cd5c83cbe39654e0f849825f484cba/Braut_Fascinator_il_570xN.410788632_mrki.jpg" }

  before do
    asset.url = "//images.ctfassets.net/01e3d4iatuxi/7wqPYZhKCc8sEYSK0UYUMW/60cd5c83cbe39654e0f849825f484cba/Braut_Fascinator_il_570xN.410788632_mrki.jpg"
  end

  describe "#discover_file_path" do
    context "when the file exists" do
      it "returns the file path" do
        allow(File).to receive(:exist?).with(file_path).and_return(true)
        expect(asset.discover_file_path(base_path)).to eq(file_path)
      end
    end

    context "when the file does not exist" do
      it "raises an error" do
        allow(File).to receive(:exist?).with(file_path).and_return(false)
        expect { asset.discover_file_path(base_path) }.to raise_error("File not found: #{file_path}")
      end
    end
  end
end