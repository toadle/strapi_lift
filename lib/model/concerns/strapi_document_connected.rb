module StrapiDocumentConnected
  extend ActiveSupport::Concern

  REQUIRED_INSTANCE_METHODS = %i[
    contentful_id
    title
    strapi_id
    strapi_id=
    strapi_api_path
    strapi_representer_class
  ]

  class_methods do
    def object_links
      @object_links ||= []
    end

    def asset_links
      @asset_links ||= []
    end

    def rich_text_fields
      @rich_text_fields ||= []
    end

    def rich_text(source:, target:)
      attr_accessor source

      define_method "#{source}_asset_urls" do
        return [] unless send(source)

        content = send(source)
        content.scan(/\(((?:https?:)?\/\/images\.ctfassets\.net\/[^)\s]+)\)/i)
          .map(&:first)
          .uniq
      end

      rich_text_fields << { source: source, target: target }
    end

    def link_object(source:, target:)
      attr_accessor source
      object_links << { source: source, target: target }
    end

    def link_asset(source:, target:)
      attr_accessor source
      asset_links << { source: source, target: target }
    end
  end

  def save!(follow_object_links: true)
    if follow_object_links
      self.class.object_links.each do |link|
        link_object = public_send(link[:source])
        raise "Link object can not be resolved" unless link_object.respond_to?(:resolve_link)
        resolved = link_object.resolve_link
        resolved.save!(follow_object_links: false)
        instance_variable_set("@#{link[:target]}", resolved)
      end
    end

    self.class.rich_text_fields.each do |rich_text|
      content = public_send(rich_text[:source])
      next unless content

      asset_urls = public_send("#{rich_text[:source]}_asset_urls")
      asset_urls.each do |asset_url|
        asset_link = Contentful::AssetLink.from_url(asset_url)
        asset = asset_link.resolve_link
        asset.save!

        content.gsub!(asset_url, asset.strapi_file_url)
      end

      public_send("#{rich_text[:source]}=", content)
    end

    self.class.asset_links.each do |link|
      link_asset = public_send(link[:source])
      raise "Link asset can not be resolved" unless link_asset.respond_to?(:resolve_link)
      resolved = link_asset.resolve_link
      if resolved
        resolved.save!
        instance_variable_set("@#{link[:target]}_id", resolved.strapi_file_id)
      end
    end

    save_to_strapi! unless present_in_strapi?
    update_connections!
  end

  def connections_data
    data = {}

    self.class.object_links.each do |link|
      obj = instance_variable_get("@#{link[:target]}")
      data[link[:target].to_s.camelize(:lower)] = { "connect" => [obj.strapi_id] }
    end

    self.class.asset_links.each do |link|
      asset_id = instance_variable_get("@#{link[:target]}_id")
      data[link[:target].to_s.camelize(:lower)] = asset_id
    end

    data
  end

  def ensure_strapi_methods!
    missing = REQUIRED_INSTANCE_METHODS.reject { |m| respond_to?(m) }
    unless missing.empty?
      raise NotImplementedError, "Missing required method(s) for StrapiDocumentConnected: #{missing.join(', ')}"
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