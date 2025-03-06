require "faraday"

module Strapi
  class Connection
    attr_reader :conn

    delegate :get, :post, :put, :patch, :delete, to: :conn

    def initialize
      @conn = Faraday.new(
        url: ENV.fetch("STRAPI_URL"),
        headers: {
          Authorization: "Bearer #{ENV.fetch("STRAPI_API_TOKEN")}"
        }
      ) do |connection|
        connection.adapter Faraday.default_adapter
        connection.request :json
        connection.response :json
        connection.response :raise_error
      end
    end
  end
end