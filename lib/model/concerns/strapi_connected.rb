module StrapiConnected
  extend ActiveSupport::Concern

  REQUIRED_INSTANCE_METHODS = %i[
    contentful_id
    title
    strapi_id
    strapi_id=
    strapi_api_path
    strapi_representer_class
  ]

  def ensure_strapi_methods!
    missing = REQUIRED_INSTANCE_METHODS.reject { |m| respond_to?(m) }
    unless missing.empty?
      raise NotImplementedError, "Missing required method(s) for StrapiSyncable: #{missing.join(', ')}"
    end
  end

  def present_in_strapi?
    ensure_strapi_methods!
    return true if self.strapi_id

    response = strapi_connection.get(strapi_api_path, {
      filters: {
        contentfulId: { "$eq": contentful_id }
      }
    })

    if response.success?
      strapi_entry = response.body.dig("data", 0)
      if strapi_entry
        self.strapi_id = strapi_entry["documentId"]
        puts "#{strapi_entry_type_name} #{title} already exists in Strapi with ID #{strapi_id}."
        return true
      end
    end

    false
  end

  def save_to_strapi!
    ensure_strapi_methods!
    representer = strapi_representer_class.new(self)
    data = representer.to_hash.transform_keys { |key| key.to_s.camelize(:lower) }

    response = strapi_connection.post(strapi_api_path, { data: data })

    if response.success?
      self.strapi_id = response.body.dig("data", "documentId")
      puts "#{strapi_entry_type_name} #{title} imported successfully as #{strapi_id}."
    end
  rescue StandardError => e
    puts "Failed to import #{strapi_entry_type_name} #{title}: #{e.message}"
  end

  def update_connections!
    return unless respond_to?(:connections_data) && connections_data.present?

    begin
      response = strapi_connection.put(strapi_api_path + "/#{self.strapi_id}", {data: connections_data})
      if response.success?
        puts "Connections for #{strapi_entry_type_name} #{title} updated successfully."
      end
    rescue StandardError => e
      puts "Failed to update connections for #{strapi_entry_type_name} #{title}: #{e.message}"
    end
  end

  private

  def strapi_entry_type_name
    self.class.name
  end

  def strapi_connection
    @strapi_connection ||= Strapi::Connection.new
  end
end