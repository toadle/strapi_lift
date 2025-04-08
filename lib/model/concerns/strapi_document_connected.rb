module StrapiDocumentConnected
  extend ActiveSupport::Concern

  REQUIRED_INSTANCE_METHODS = %i[
    title
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

    def single_content_type!
      @single_content_type = true
    end

    def single_content_type?
      @single_content_type
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

    def link_object(source:, target:, always_resolve: false)
      attr_accessor source
      object_links << { source: source, target: target, always_resolve: always_resolve }
    end

    def link_asset(source:, target:)
      attr_accessor source
      asset_links << { source: source, target: target }
    end

    def link_objects(source:, target:, always_resolve: false)
      attr_accessor source
      object_links << { source: source, target: target, multiple: true, always_resolve: always_resolve }
    end

    def link_assets(source:, target:)
      attr_accessor source
      asset_links << { source: source, target: target, multiple: true }
    end

    def reset_strapi!
      connection = Strapi::Connection.new
      if single_content_type?
        begin
          connection.get(strapi_api_path).body.dig("data").present?
          connection.delete(strapi_api_path)
          $logger.log_progress("Deleted successfully.", self.name, :info)
        rescue Faraday::ResourceNotFound
          # pass
        end
      else
        connection.get(strapi_api_path).body.dig("data").each do |document|
          connection.delete("#{strapi_api_path}/#{document['documentId']}")
          $logger.log_progress("Deleted strapi ID #{document['documentId']} successfully.", self.name, :info)
        end
      end
    end

    def strapi_representer_class
      @strapi_representer_class ||= begin
        name.gsub("Contentful", "Strapi") + "Representer"
      end.constantize
    end

    def contentful_representer_class
      @contentful_representer_class ||= begin
        name + "Representer"
      end.constantize
    end
  end

  def save!(follow_object_links: true)
    self.class.object_links.each do |link|
      next unless follow_object_links || (link[:always_resolve] && !present_in_strapi?)

      link_objects = Array(public_send(link[:source]))
      resolved_objects = link_objects.map do |link_object|
        raise "Link object can not be resolved" unless link_object.respond_to?(:resolve_link)
        resolved = link_object.resolve_link
        resolved.save!(follow_object_links: false)
        resolved
      end

      instance_variable_set("@#{link[:target]}", link[:multiple] ? resolved_objects : resolved_objects.first)
    end

    unless present_in_strapi?
      self.class.rich_text_fields.each do |rich_text|
        content = public_send(rich_text[:source])
        next unless content

        asset_urls = public_send("#{rich_text[:source]}_asset_urls")
        asset_urls.each do |asset_url|
          asset_link = Contentful::AssetLink.from_url(asset_url)
          asset = asset_link.resolve_link
          asset.save!

          begin
            content.gsub!(asset_url, asset.strapi_file_url)
          rescue StandardError => e
            $logger.log_progress("Error replacing asset URL: #{asset_url} in '#{rich_text[:source]}'", self.class.name, :error, contentful_id)
          end
        end

        public_send("#{rich_text[:source]}=", content)
      end

      self.class.asset_links.each do |link|
        link_assets = Array(public_send(link[:source]))
        resolved_assets = link_assets.map do |link_asset|
          raise "Link asset can not be resolved" unless link_asset.respond_to?(:resolve_link)
          resolved = link_asset.resolve_link
          if resolved
            resolved.save!
            resolved.strapi_file_id
          end
        end.compact

        instance_variable_set("@#{link[:target]}#{link[:multiple] ? '_ids' : '_id'}", link[:multiple] ? resolved_assets : resolved_assets.first)
      end

      save_to_strapi!
    end

    update_connections!
  rescue Faraday::BadRequestError => e
    $logger.log_progress(JSON.parse(e.response.fetch(:body)).dig("error", "message"), self.class.name, :error, name)
    raise e
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

    if self.class.single_content_type?
      begin
        return strapi_connection.get(self.class.strapi_api_path).body.dig("data").present?
      rescue Faraday::ResourceNotFound
        return false
      end
    end

    response = strapi_connection.get(self.class.strapi_api_path, {
      filters: {
        contentfulId: { "$eq": contentful_id }
      }
    })
  
    strapi_entry = response.body.dig("data", 0)
    if strapi_entry
      self.strapi_id = strapi_entry["documentId"]
      $logger.log_progress("Already exists in strapi with ID #{strapi_id}.", self.class.name, :info, contentful_id)
      return true
    end

    false
  rescue Faraday::BadRequestError => e
    $logger.log_progress(JSON.parse(e.response.fetch(:body)).dig("error", "message"), self.class.name, :error, contentful_id)
    raise e
  end

  def save_to_strapi!
    ensure_strapi_methods!
    representer = self.class.strapi_representer_class.new(self)
    data = representer.to_hash.transform_keys { |key| key.to_s.camelize(:lower) }

    if self.class.single_content_type?
      data.delete("contentfulId")
      response = strapi_connection.put(self.class.strapi_api_path, { data: data }) if self.class.single_content_type?
    else
      response = strapi_connection.post(self.class.strapi_api_path, { data: data }) unless self.class.single_content_type?
    end

    self.strapi_id = response.body.dig("data", "documentId")
    $logger.log_progress("Imported successfully as #{strapi_id}.", self.class.name, :info, contentful_id)
  end

  def update_connections!
    return unless respond_to?(:connections_data) && connections_data.present?

    strapi_connection.put(self.class.strapi_api_path + "/#{self.strapi_id}", {data: connections_data}) unless self.class.single_content_type?
    strapi_connection.put(self.class.strapi_api_path, {data: connections_data}) if self.class.single_content_type?
    $logger.log_progress("Connections updated successfully.", self.class.name, :info, contentful_id)
  end

  private

  def strapi_entry_type_name
    self.class.name
  end

  def strapi_connection
    @strapi_connection ||= Strapi::Connection.new
  end
end