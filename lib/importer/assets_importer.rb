class AssetsImporter
  def run(assets_data)
    response = strapi_connection.upload_file("/Users/tim/Desktop/to_adle_a_hideous_funny_bride_f63909ed-d692-43bb-82a8-d31e96b7e291.png")
    begin
      response = strapi_connection.update_file_info(response.first.fetch("id"), {
        "alternativeText": "A hideous little bride", caption: "Come from the deep" 
      })
    rescue StandardError => e
      binding.pry
    end
  end

  def strapi_connection
    @strapi_connection ||= Strapi::Connection.new
  end
end