require "faraday"

module Strapi
  class Connection
    attr_reader :conn

    delegate :get, :post, :put, :patch, :delete, to: :conn

    def initialize
      @conn = Faraday.new(
        url: ENV.fetch("STRAPI_URL"),
        headers: {
          Authorization: "Basic #{ENV.fetch("STRAPI_API_TOKEN")}",
          "Content-Type": "application/json"
        }
      ) do |connection|
        connection.adapter Faraday.default_adapter
      end
    end
  end
end
