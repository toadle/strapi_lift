class AssetsImporter
  def run(assets_data, assets_folder)
    assets_data[0..4].each do |asset_data|
      asset = Contentful::Asset.new
      Contentful::AssetRepresenter.new(asset).from_hash(asset_data)

      begin
        file_path = asset.discover_file_path(assets_folder)
        upload_response = strapi_connection.upload_file(file_path)
        file_id = upload_response.first["id"]

        if file_id
          metadata = {
            caption: asset.title,
            alternativeText: asset.description
          }
          strapi_connection.update_file_info(file_id, metadata)
          puts "Asset #{asset.title} uploaded successfully."
        else
          puts "Failed to upload asset #{asset.title}."
        end
      rescue StandardError => e
        puts "Error uploading asset #{asset.title}: #{e.message}"
      end
    end
  end

  def strapi_connection
    @strapi_connection ||= Strapi::Connection.new
  end
end