module StrapiDocumentConnected
  extend ActiveSupport::Concern

  REQUIRED_INSTANCE_METHODS = %i[
    title
    strapi_representer_class
  ]

  included do
    attr_accessor :strapi_id
    attr_accessor :contentful_id
  end

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

    def strapi_api_path
      @strapi_api_path
    end

    def api_path(path)
      @strapi_api_path = path
    end

    def rich_text(source:, target:)
      attr_accessor source

      define_method "#{source}_asset_urls" do
        return [] unless send(source)

        content = send(source)
        content.scan(/\(((?:https?:)?\/\/images\.(?:ctfassets\.net|contentful\.com)\/[^)\s]+)\)/i)
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

    def link_objects(source:, target:)
      attr_accessor source
      object_links << { source: source, target: target, multiple: true }
    end

    def link_assets(source:, target:)
      attr_accessor source
      asset_links << { source: source, target: target, multiple: true }
    end

    def reset_strapi!
      connection = Strapi::Connection.new
      response = connection.get(strapi_api_path)
      documents = response.body.dig("data") || []

      documents.each do |document|
        connection.delete("#{strapi_api_path}/#{document['documentId']}")
        puts "#{name} with ID #{document['documentId']} deleted successfully."
      end
    end
  end

  def save!(follow_object_links: true)
    if follow_object_links
      self.class.object_links.each do |link|
        if link[:multiple]
          link_objects = public_send(link[:source]) || []
          resolved_objects = link_objects.map do |link_object|
            raise "Link object can not be resolved" unless link_object.respond_to?(:resolve_link)
            resolved = link_object.resolve_link
            resolved.save!(follow_object_links: false)
            resolved
          end
          instance_variable_set("@#{link[:target]}", resolved_objects)
        else
          link_object = public_send(link[:source])
          raise "Link object can not be resolved" unless link_object.respond_to?(:resolve_link)
          resolved = link_object.resolve_link
          resolved.save!(follow_object_links: false)
          instance_variable_set("@#{link[:target]}", resolved)
        end
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
      if link[:multiple]
        link_assets = public_send(link[:source]) || []
        resolved_assets = link_assets.map do |link_asset|
          raise "Link asset can not be resolved" unless link_asset.respond_to?(:resolve_link)
          resolved = link_asset.resolve_link
          if resolved
            resolved.save!
            resolved.strapi_file_id
          end
        end.compact
        instance_variable_set("@#{link[:target]}_ids", resolved_assets)
      else
        link_asset = public_send(link[:source])
        raise "Link asset can not be resolved" unless link_asset.respond_to?(:resolve_link)
        resolved = link_asset.resolve_link
        if resolved
          resolved.save!
          instance_variable_set("@#{link[:target]}_id", resolved.strapi_file_id)
        end
      end
    end

    save_to_strapi! unless present_in_strapi?
    update_connections!
  end

  def connections_data
    data = {}

    self.class.object_links.each do |link|
      if link[:multiple]
        objs = instance_variable_get("@#{link[:target]}") || []
        next if objs.empty?

        data[link[:target].to_s.camelize(:lower)] = { "connect" => objs.map(&:strapi_id) }
      else
        obj = instance_variable_get("@#{link[:target]}")
        next unless obj

        data[link[:target].to_s.camelize(:lower)] = { "connect" => [obj.strapi_id] }
      end
    end

    self.class.asset_links.each do |link|
      if link[:multiple]
        asset_ids = instance_variable_get("@#{link[:target]}_ids") || []
        next if asset_ids.empty?

        data[link[:target].to_s.camelize(:lower)] = asset_ids
      else
        asset_id = instance_variable_get("@#{link[:target]}_id")
        next unless asset_id

        data[link[:target].to_s.camelize(:lower)] = asset_id
      end
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

    response = strapi_connection.get(self.class.strapi_api_path, {
      filters: {
        contentfulId: { "$eq": contentful_id }
      }
    })

  
    strapi_entry = response.body.dig("data", 0)
    if strapi_entry
      self.strapi_id = strapi_entry["documentId"]
      puts "#{strapi_entry_type_name} #{title} already exists in Strapi with ID #{strapi_id}."
      return true
    end

    false
  end

  def save_to_strapi!
    ensure_strapi_methods!
    representer = strapi_representer_class.new(self)
    data = representer.to_hash.transform_keys { |key| key.to_s.camelize(:lower) }

    response = strapi_connection.post(self.class.strapi_api_path, { data: data })

    self.strapi_id = response.body.dig("data", "documentId")
    puts "#{strapi_entry_type_name} #{title} imported successfully as #{strapi_id}."
  end

  def update_connections!
    return unless respond_to?(:connections_data) && connections_data.present?

    strapi_connection.put(self.class.strapi_api_path + "/#{self.strapi_id}", {data: connections_data})
    puts "Connections for #{strapi_entry_type_name} #{title} updated successfully."
  end

  private

  def strapi_entry_type_name
    self.class.name
  end

  def strapi_connection
    @strapi_connection ||= Strapi::Connection.new
  end
end