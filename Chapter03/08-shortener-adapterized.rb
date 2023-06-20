require_relative "./prelude"

# Shortener with adapters
class Shortener
  class << self
    attr_writer :backend

    delegate :shorten, to: :backend

    def backend
      @backend ||= BitlyBackend.new
    end
  end

  class BitlyBackend
    def initialize(token: Rails.credentials.bitly_api_token)
      @client = Bitly::API::Client.new(token:)
    end

    def shorten(long_url)
      @client.shorten(long_url:).link
    end
  end

  class NoOpBackend
    def shorten(url) = url
  end
end

Shortener.shorten("https://rubyonrails.org")

# Switch adapter to no-op (returning the long url)
Shortener.backend = Shortener::NoOpBackend.new

Shortener.shorten("https://rubyonrails.org")
