require "json"
require "http/client"
require "money"
require "./ext/**"

class Stripe::Client
  property api_key : String
  property version : String?

  BASE_URL = URI.parse("https://api.stripe.com")

  def initialize(@api_key, @version = nil)
  end

  def http_client : HTTP::Client
    return @http_client.not_nil! unless @http_client.nil?

    reset_client

    @http_client.not_nil!
  end

  def reset_client
    @http_client = HTTP::Client.new(BASE_URL)

    if !@version.nil?
      @http_client.not_nil!.before_request do |request|
        request.headers["Authorization"] = "Bearer #{api_key}"
        request.headers["Stripe-Version"] = version.not_nil!
      end
    else
      @http_client.not_nil!.before_request do |request|
        request.headers["Authorization"] = "Bearer #{api_key}"
      end
    end
  end
end

require "./stripe/**"