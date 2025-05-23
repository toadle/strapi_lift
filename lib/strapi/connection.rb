require "faraday"
require 'faraday/multipart'
require "mime/types"

DEFAULT_RETRY_ERRORS = [
  Net::ReadTimeout,
  Faraday::TimeoutError,
  Faraday::ConnectionFailed
]

require_relative "retry_proxy"

module Strapi
  class Connection
    attr_reader :conn

    delegate :get, :post, :put, :patch, :delete, to: :conn

    def initialize
      raw_conn = Faraday.new(
        url: ENV.fetch("STRAPI_URL"),
        headers: {
          Authorization: "Bearer #{ENV.fetch("STRAPI_API_TOKEN")}"
        }
      ) do |connection|
        connection.adapter Faraday.default_adapter
        connection.request :multipart
        connection.request :json
        connection.response :json
        connection.response :raise_error
      end

      @conn = RetryProxy.new(raw_conn, attempts: 3, on: DEFAULT_RETRY_ERRORS)
    end

    def upload_file(file_path)
      unless File.exist?(file_path) && File.size(file_path).positive?
        raise "File not found or empty: #{file_path}"
      end

      mime_type = MIME::Types.type_for(file_path).first.to_s || "application/octet-stream"
      file = Faraday::UploadIO.new(file_path, mime_type)
      response = conn.post("/api/upload") do |req|
        req.body = { files: file }
      end
      response.body
    end

    def update_file_info(file_id, metadata)
      response = conn.post("/api/upload?id=#{file_id}") do |req|
        req.body = { fileInfo: metadata.to_json }
      end
      response.body
    end

    def find_file_by_name(file_name)
      response = conn.get("/api/upload/files", {
        filters: {
          "name": { "$eq": file_name }
        }
      })
      if response.success?
        return response.body.first if response.body.any?
      end
    end
  end
end