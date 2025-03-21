require 'uri'

module Contentful
  class Asset
    attr_accessor :title, :description, :file_name, :space_id, :contenful_id, :url

    def discover_file_path(base_path)
      file_path = File.join(base_path, URI.parse(url).path)
      raise "File not found: #{file_path}" unless File.exist?(file_path)
      file_path
    end
  end
end
